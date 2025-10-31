import 'dart:io';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/data/repositories/restaurant_repository_impl.dart';
import 'package:back_garson/data/repositories/restaurant_theme_repository_impl.dart';
import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('StatusRoute');

Future<Response> onRequest(RequestContext context, String tableId) async {
  _log.info('Запрос на /web/status/$tableId');
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final tableRepo = TableRepositoryImpl(pool);
  final restaurantRepo = RestaurantRepositoryImpl(pool);
  final themeRepo = RestaurantThemeRepositoryImpl(pool);
  final orderRepo = OrderRepositoryImpl(pool);
  final orderService = OrderService(orderRepo);

  try {
    final table = await tableRepo.getTableById(tableId);
    final restaurantId = table.restaurantId;

    final futures = <Future<dynamic>>[
      restaurantRepo.getRestaurantById(restaurantId),
      themeRepo.getRestaurantThemeById(restaurantId),
    ];
    final results = await Future.wait(futures);
    final restaurant = results[0] as RestaurantModel;
    final theme = results[1] as RestaurantThemeModel;

    String? token;
    Order? order;
    String? sessionId;

    final authHeader = context.request.headers[HttpHeaders.authorizationHeader];
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      final receivedToken = authHeader.substring(7);
      try {
        final jwt = JWT.verify(receivedToken, SecretKey(Config.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        sessionId = payload['sessionId'] as String?;

        if (sessionId != null) {
          _log.info('Найден sessionId $sessionId в токене.');
          final orderId = await orderRepo.findActiveOrderIdBySession(sessionId);
          if (orderId != null) {
            _log.info('Найден активный заказ $orderId для этой сессии.');
            order = await orderRepo.getOrder(orderId);
          }
        }
        if (order != null) {
          token = receivedToken;
        }
      } catch (_) {
        // Токен невалидный, будем создавать новую сессию
      }
    }

    if (order == null) {
      _log.info('Активный заказ по сессии не найден, ищем для столика...');
      order = await orderRepo.findActiveOrderByTable(tableId);
      sessionId = const Uuid().v4(); // В любом случае создаем новую сессию

      if (order == null) {
        _log.info('Активный заказ для столика не найден, создаю новый заказ с новой сессией $sessionId');
        order = await orderService.createOrder(tableId, sessionId: sessionId);
      } else {
        _log.info('Найден заказ ${order.orderId}, привязываю к нему новую сессию $sessionId');
        await orderRepo.updateSessionId(order.orderId, sessionId);
      }
    }

    if (token == null) {
      final jwt = JWT({
        'role': 'CUSTOMER',
        'tableId': table.id,
        'restaurantId': restaurantId,
        'sessionId': sessionId,
      });
      token = jwt.sign(SecretKey(Config.jwtSecret), expiresIn: const Duration(hours: 24));
    }

    return Response.json(
      body: {
        'token': token,
        'table': (table as TableModel).toJson(),
        'restaurant': restaurant.toJson(),
        'theme': theme.toJson(),
        'order': (order as OrderModel).toJson(),
      },
    );
  } catch (e, st) {
    _log.severe('Ошибка в /web/status/$tableId', e, st);
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Не удалось загрузить данные: $e'},
    );
  }
}