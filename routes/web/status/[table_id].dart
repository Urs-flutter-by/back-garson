import 'dart:io';

import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/data/repositories/restaurant_repository_impl.dart';
import 'package:back_garson/data/repositories/restaurant_theme_repository_impl.dart';
import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// Обрабатывает первоначальный запрос от клиента, сканирующего QR-код.
/// Собирает всю необходимую для старта информацию и генерирует гостевой токен.
Future<Response> onRequest(RequestContext context, String tableId) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final tableRepo = TableRepositoryImpl(pool);
  final restaurantRepo = RestaurantRepositoryImpl(pool);
  final themeRepo = RestaurantThemeRepositoryImpl(pool);

  try {
    // Шаг 1: Получаем данные о столике.
    final table = await tableRepo.getTableById(tableId);
    final restaurantId = table.restaurantId;

    // Шаг 2: Параллельно запрашиваем данные о ресторане и теме.
    final futures = [
      restaurantRepo.getRestaurantById(restaurantId),
      themeRepo.getRestaurantThemeById(restaurantId),
    ];
    final results = await Future.wait(futures);
    final restaurant = results[0] as RestaurantModel;
    final theme = results[1] as RestaurantThemeModel;

    // Шаг 3: Генерируем гостевой JWT.
    final jwt = JWT(
      {
        'role': 'CUSTOMER',
        'tableId': table.id,
        'restaurantId': restaurantId,
        'sessionId': const Uuid().v4(),
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
    );
    final token = jwt.sign(
      SecretKey(Config.jwtSecret),
      expiresIn: const Duration(hours: 24),
    );

    // Шаг 4: Собираем и возвращаем итоговый JSON.
    return Response.json(
      body: {
        'token': token,
        'table': (table as TableModel).toJson(),
        'restaurant': restaurant.toJson(),
        'theme': theme.toJson(),
      },
    );
  } catch (e) {
    // Если любой из запросов не удался, возвращаем ошибку.
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Не удалось загрузить данные: $e'},
    );
  }
}
