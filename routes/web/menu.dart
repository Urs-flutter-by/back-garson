import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/data/models/menu_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final menuService = context.read<MenuService>();
  final db = DatabaseSource();

  try {
    // Извлекаем Bearer-токен из заголовка Authorization
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization header with Bearer token is required'},
      );
    }

    final orderId = authHeader.substring(7); // Убираем "Bearer "

    // Проверяем, существует ли заказ с таким orderId
    final conn = await db.connection;
    final orderResult = await conn.execute(
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

    final restaurantId = orderResult[0][0].toString();

    // Получаем меню ресторана
    final menu = await menuService.getMenuByRestaurantId(restaurantId);
    final menuModel = menu as MenuModel; // Приводим к MenuModel
    return Response.json(body: menuModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to get menu: $e'},
    );
  } finally {
    await db.close();
  }
}
