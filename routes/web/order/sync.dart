import 'dart:convert';
import 'dart:io';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

final _log = Logger('WebOrderSyncRoute');

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));
  final payload = context.read<AuthPayload>();
  final tableId = payload.tableId;

  if (tableId == null) {
    return Response.json(statusCode: 400, body: {'error': 'tableId not found in token'});
  }

  try {
    final activeOrderResult = await pool.withConnection((conn) => conn.execute(
          r'''
          SELECT order_id FROM orders 
          WHERE table_id = $1 AND status NOT IN ('completed', 'canceled')
          ORDER BY created_at DESC LIMIT 1
          ''',
          parameters: [tableId],
        ));

    String orderId;
    if (activeOrderResult.isNotEmpty) {
      orderId = activeOrderResult.first.toColumnMap()['order_id'] as String;
    } else {
      final newOrder = await orderService.createOrder(tableId, sessionId: payload.sessionId);
      orderId = newOrder.orderId;
    }

    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>?;

    if (itemsJson == null) {
      return Response.json(statusCode: 400, body: {'error': 'items field is required'});
    }

    final items = itemsJson.map((itemJson) {
      final itemData = itemJson as Map<String, dynamic>;
      return OrderItemModel(
        dishId: itemData['dishId'] as int,
        quantity: itemData['quantity'] as int,
        status: 'new', // Status is handled by the backend
        comment: itemData['comment'] as String?,
        course: itemData['course'] as int? ?? 1,
        serveAt: itemData['serveAt'] != null ? DateTime.tryParse(itemData['serveAt'] as String) : null,
      );
    }).toList();

    await orderService.syncOrderItems(orderId, items, payload);

    final updatedOrder = await orderService.getOrder(orderId);

    if (updatedOrder == null) {
      return Response.json(statusCode: 404, body: {'error': 'Order not found after sync'});
    }

    return Response.json(body: (updatedOrder as OrderModel).toJson());

  } catch (e, st) {
    _log.severe('Error syncing order', e, st);
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error'},
    );
  }
}