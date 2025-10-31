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
        actorId: actor.userId,
      );
    }

    // Если заказ новый, используем bulkInsert, иначе - diffAndSync
    if (order != null && order.status == 'new') {
      return repository.bulkInsertItems(orderId, items);
    } else {
      return repository.diffAndSyncItems(orderId, items, actor);
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String? actorId,
  }) async {
    _log.info(
      'User ${actorId} is changing status of order $orderId to $newStatus',
    );

    await repository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      actorId: actorId,
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

    /// TODO: Add logic to notify the customer.

    for (final targetId in targets) {
      if (actorId != targetId) {
        ConnectionManager.instance.sendMessage(targetId, message);
      }
    }
  }
}
