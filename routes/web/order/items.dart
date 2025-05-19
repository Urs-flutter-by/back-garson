import 'dart:convert';
import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final orderService = context.read<OrderService>();

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
      final dishId = itemJson['dishId'] as String?;
      final quantityRaw = itemJson['quantity'];

      if (dishId == null) {
        throw Exception('dishId is required');
      }
      final quantity = quantityRaw is int
          ? quantityRaw
          : int.tryParse(quantityRaw.toString()) ??
              (throw Exception('Invalid quantity: $quantityRaw'));

      return OrderItemModel(
        dishId: dishId,
        quantity: quantity,
        status: 'new',
        dish: null, // dish не передаём, так как его нет в JSON
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
