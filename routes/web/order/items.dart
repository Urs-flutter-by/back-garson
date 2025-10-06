import 'dart:convert';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));

  try {
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization header with Bearer token is required'},
      );
    }

    final orderId = authHeader.substring(7);

    // Парсим тело запроса
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>?;

    if (itemsJson == null || itemsJson.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Items list is required and cannot be empty'},
      );
    }

    final items = itemsJson.map((itemJson) {
      final itemData = itemJson as Map<String, dynamic>;
      final dishId = itemData['dishId'] as String?;
      final quantityRaw = itemData['quantity'];
      final comment = itemData['comment'] as String?;
      final courseRaw = itemData['course'];
      final serveAt = itemData['serveAt'] as String?;

      if (dishId == null) {
        throw Exception('dishId is required');
      }
      final quantity = quantityRaw is int
          ? quantityRaw
          : int.tryParse(quantityRaw.toString()) ??
              (throw Exception('Invalid quantity: $quantityRaw'));
      final course = courseRaw is int
          ? courseRaw
          : int.tryParse(courseRaw?.toString() ?? '1') ?? 1;
      if (course < 1 || course > 10) {
        throw Exception('Invalid course: must be between 1 and 10');
      }
      final serveAtDate = serveAt != null ? DateTime.tryParse(serveAt) : null;
      if (serveAt != null && serveAtDate == null) {
        throw Exception('Invalid serveAt: must be a valid ISO 8601 date');
      }

      return OrderItemModel(
        dishId: dishId,
        quantity: quantity,
        status: 'new',
        comment: comment,
        course: course,
        serveAt: serveAtDate,
      );
    }).toList();

    await orderService.addOrderItems(orderId, items);

    return Response.json(
      body: {'message': 'Order items added successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to add order items: $e'},
    );
  }
}
