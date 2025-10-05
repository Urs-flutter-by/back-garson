import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String tableId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));

  try {
    final order = await orderService.createOrder(tableId);
    return Response.json(body: {'orderId': order.orderId, 'success': true});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to create order: $e', 'success': false},
    );
  }
}
