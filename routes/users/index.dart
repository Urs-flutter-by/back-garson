import 'dart:io';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:back_garson/presentation/middleware/authorization_middleware.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  // Защищаем весь эндпоинт цепочкой middleware.
  // Сначала проверяем аутентификацию, затем авторизацию (право user:create).
  final handler = _handler.use(authorizationMiddleware('user:create')).use(authenticationMiddleware());
  final response = await handler(context);
  return response;
}

// Основная логика эндпоинта, которая выполнится только после прохождения всех проверок.
Future<Response> _handler(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _createUser(context);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

/// Создает нового пользователя (сотрудника).
Future<Response> _createUser(RequestContext context) async {
  final pool = context.read<Pool<void>>();
  // Получаем данные администратора, который выполняет действие.
  final adminPayload = context.read<AuthPayload>();
  final body = await context.request.json() as Map<String, dynamic>;

  // Данные для нового пользователя из тела запроса.
  final login = body['login'] as String?;
  final password = body['password'] as String?;
  final name = body['name'] as String?;
  final role = body['role'] as String?;
  final restaurantId = body['restaurantId'] as String?;

  if (login == null || password == null || name == null || role == null || restaurantId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Все поля обязательны'});
  }

  // Роль нового пользователя должна быть либо WAITER, либо CHEF.
  if (role != 'WAITER' && role != 'CHEF') {
    return Response.json(statusCode: 400, body: {'error': 'Недопустимая роль'});
  }

  try {
    return await pool.runTx((ctx) async {
      // 1. Определяем account_id администратора.
      final adminResult = await ctx.execute(
        'SELECT account_id FROM users WHERE id = @id',
        parameters: {'id': adminPayload.userId},
      );
      if (adminResult.isEmpty) {
        return Response.json(statusCode: 403, body: {'error': 'Не удалось определить аккаунт администратора'});
      }
      final accountId = adminResult.first.toColumnMap()['account_id'] as String;

      // 2. Получаем лимиты подписки.
      final subResult = await ctx.execute(
        'SELECT max_waiters FROM subscriptions WHERE account_id = @id AND status = \'active\'',
        parameters: {'id': accountId},
      );
      if (subResult.isEmpty) {
        return Response.json(statusCode: 403, body: {'error': 'Активная подписка не найдена'});
      }
      final maxUsers = subResult.first.toColumnMap()['max_waiters'] as int;

      // 3. Считаем текущее количество сотрудников (официантов + поваров).
      final countResult = await ctx.execute(
        'SELECT COUNT(id) FROM users WHERE account_id = @id AND (role = \'WAITER\' OR role = \'CHEF\')',
        parameters: {'id': accountId},
      );
      final currentUserCount = countResult.first.toColumnMap()['count'] as int;

      // 4. Проверяем лимит.
      if (currentUserCount >= maxUsers) {
        return Response.json(
          statusCode: HttpStatus.forbidden, // 403 Forbidden
          body: {'error': 'Достигнут лимит сотрудников ($maxUsers) по вашей подписке'},
        );
      }

      // 5. Если лимит не превышен, создаем нового пользователя.
      final passwordHash = DBCrypt().hashpw(password, DBCrypt().gensalt());
      await ctx.execute(
        '''
        INSERT INTO users (name, login, password_hash, role, restaurant_id, account_id)
        VALUES (@name, @login, @hash, @role, @restId, @accId)
        ''',
        parameters: {
          'name': name,
          'login': login,
          'hash': passwordHash,
          'role': role,
          'restId': restaurantId,
          'accId': accountId,
        },
      );

      return Response(statusCode: HttpStatus.created); // 201 Created
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Ошибка базы данных: $e'});
  }
}
