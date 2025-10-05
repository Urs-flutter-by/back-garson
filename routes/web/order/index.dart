import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool>();
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
    final order = await orderService.getOrder(orderId);

    if (order == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Order not found'},
      );
    }

    return Response.json(body: (order as OrderModel).toJson());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to get order: $e'},
    );
  }
}
