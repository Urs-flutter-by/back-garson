import 'package:back_garson/application/services/order_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String tableId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final service = context.read<OrderService>();

  try {
    final order = await service.createOrder(tableId);

    return Response.json(body: {
      'orderId': order.orderId,
    },);
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to create order: $e'},
    );
  }
}