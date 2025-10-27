import 'dart:convert';
import 'dart:io';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String orderId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));

  try {
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>?;

    if (itemsJson == null) {
      return Response.json(statusCode: 400, body: {'error': 'Поле items обязательно'});
    }

    final items = itemsJson.map((itemJson) {
      final itemData = itemJson as Map<String, dynamic>;
      final dishId = itemData['dishId'] as int;
      final quantity = itemData['quantity'] as int;
      final comment = itemData['comment'] as String?;
      final course = itemData['course'] as int? ?? 1;
      final serveAt = itemData['serveAt'] != null
          ? DateTime.tryParse(itemData['serveAt'] as String)
          : null;

      return OrderItemModel(
        dishId: dishId,
        quantity: quantity,
        status: 'new',
        comment: comment,
        course: course,
        serveAt: serveAt,
      );
    }).toList();

    await orderService.syncOrderItems(orderId, items);
    
    return Response.json(
      body: {'success': true, 'message': 'Order items synced successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Внутренняя ошибка сервера: $e'},
    );
  }
}