import 'dart:io';

import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// Обрабатывает первоначальный запрос от клиента, сканирующего QR-код.
/// Проверяет, что столик существует, и генерирует для сессии клиента
/// гостевой JWT-токен с ролью CUSTOMER.
Future<Response> onRequest(RequestContext context, String tableId) async {
  // Для этого эндпоинта разрешаем только GET-запросы
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  // Используем репозиторий напрямую для простой проверки
  final tableRepo = TableRepositoryImpl(pool);

  try {
    // Шаг 1: Проверяем, существует ли столик с таким ID.
    final table = await tableRepo.getTableById(tableId);

    // Шаг 2: Если столик существует, генерируем для этой сессии JWT.
    final jwt = JWT(
      {
        'role': 'CUSTOMER', // Жестко задаем роль гостя
        'tableId': table.id,
        'restaurantId': table.restaurantId,
        'sessionId': const Uuid().v4(), // Уникальный ID для каждой сессии
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Шаг 3: Подписываем токен и устанавливаем срок действия (например, 24 часа).
    final token = jwt.sign(
      SecretKey(Config.jwtSecret),
      expiresIn: const Duration(hours: 24),
    );

    // Шаг 4: Возвращаем клиенту только токен.
    return Response.json(body: {'token': token});

  } catch (e) {
    // Если репозиторий выбросил исключение (стол не найден), возвращаем 404.
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Столик не найден'},
    );
  }
}
