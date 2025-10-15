import 'dart:convert';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String orderId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));

  try {
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>?;

    if (itemsJson == null || itemsJson.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Items list is required and cannot be empty',
          'success': false,
        },
      );
    }

    final items = itemsJson.map((itemJson) {
      final itemData = itemJson as Map<String, dynamic>;
      final dishIdRaw = itemData['dishId'];
      final quantityRaw = itemData['quantity'];
      final comment = itemData['comment'] as String?;
      final courseRaw = itemData['course'];

      if (dishIdRaw == null) throw Exception('dishId is required');
      
      final dishId = dishIdRaw is int
          ? dishIdRaw
          : int.tryParse(dishIdRaw.toString()) ?? (throw Exception('Invalid dishId'));

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

      return OrderItemModel(
        dishId: dishId, // теперь int
        quantity: quantity,
        status: 'new',
        comment: comment,
        course: course,
      );
    }).toList();

    await orderService.addOrderItems(orderId, items);
    return Response.json(
      body: {'success': true, 'message': 'Order items added successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to add order items: $e', 'success': false},
    );
  }
}
