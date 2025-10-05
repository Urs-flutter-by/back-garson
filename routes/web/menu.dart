import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/data/models/menu_model.dart';
import 'package:back_garson/data/repositories/menu_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final menuService = MenuService(MenuRepositoryImpl(pool));

  try {
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization header with Bearer token is required'},
      );
    }

    final orderId = authHeader.substring(7); // "Bearer " is 7 chars

    final orderResult = await pool.execute(
      r'''
      SELECT restaurant_id
      FROM orders
      WHERE order_id = $1
      ''',
      parameters: [orderId],
    );

    if (orderResult.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Order not found'},
      );
    }

    final restaurantId = orderResult.first[0].toString();

    final menu = await menuService.getMenuByRestaurantId(restaurantId);
    final menuModel = menu as MenuModel;
    return Response.json(body: menuModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to get menu: $e'},
    );
  }
}

