import 'dart:convert';

import 'package:back_garson/application/services/connection_manager.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:logging/logging.dart';

class OrderService {
  OrderService(this.repository);

  final OrderRepository repository;
  final _log = Logger('OrderService');

  Future<Order> createOrder(String tableId, {String? sessionId}) async {
    return repository.createOrder(tableId, sessionId: sessionId);
  }

  Future<Order?> getOrder(String orderId) async {
    return repository.getOrder(orderId);
  }

  Future<void> syncOrderItems(
      String orderId, List<OrderItem> items, AuthPayload actor) async {
    final order = await repository.getOrder(orderId);

    if (order != null && order.status == 'new' && items.isNotEmpty) {
      await updateOrderStatus(
        orderId: orderId,
        newStatus: 'pending_confirmation',
        actor: actor,
      );
    }

    return repository.syncOrderItems(orderId, items, actor);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required AuthPayload actor,
  }) async {
    _log.info(
      'User ${actor.userId ?? actor.sessionId} is changing status of order $orderId to $newStatus',
    );

    await repository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      actorId: actor.userId ?? actor.sessionId!,
    );

    final order = await repository.getOrder(orderId);
    if (order == null) return;

    final message = jsonEncode({
      'event': 'order_status_changed',
      'data': {
        'orderId': orderId,
        'newStatus': newStatus,
      },
    });

    final targets = <String>{};
    if (order.waiterId != null) targets.add(order.waiterId!);
    if (order.chefId != null) targets.add(order.chefId!);

    // TODO: Add logic to notify the customer.

    for (final targetId in targets) {
      if (targetId != actor.userId) {
        ConnectionManager.instance.sendMessage(targetId, message);
      }
    }
  }
}
