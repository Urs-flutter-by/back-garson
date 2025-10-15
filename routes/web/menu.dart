import 'dart:io';

import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/data/models/menu_model.dart';
import 'package:back_garson/data/repositories/menu_repository_impl.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    // Шаг 1: Вручную извлекаем и проверяем токен
    final authHeader = context.request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization header is required'},
      );
    }
    final token = authHeader.substring(7);

    String? restaurantId;
    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      restaurantId = payload['restaurantId'] as String?;
    } catch (e) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid or expired token'},
      );
    }

    if (restaurantId == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Token does not contain a restaurantId'},
      );
    }

    // Шаг 2: Если токен валидный, получаем меню
    final pool = context.read<Pool<void>>();
    final menuService = MenuService(MenuRepositoryImpl(pool));
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
