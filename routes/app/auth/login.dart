import 'dart:io';

import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:postgres/postgres.dart';

/// Обрабатывает вход сотрудника в систему.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final login = body['login'] as String?;
    final password = body['password'] as String?;
    final restaurantId = body['restaurantId'] as String?;

    if (login == null || password == null || restaurantId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Поля login, password и restaurantId обязательны'},
      );
    }

    // Ищем пользователя в новой таблице users
    final result = await pool.withConnection((conn) async {
      return conn.execute(
        r'''
        SELECT id, password_hash, role 
        FROM users 
        WHERE login = @login AND restaurant_id = @restaurantId AND is_active = true
        ''',
        parameters: {
          'login': login,
          'restaurantId': restaurantId,
        },
      );
    });

    if (result.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Неверный логин или пароль'},
      );
    }

    final userRow = result.first.toColumnMap();
    final storedHash = userRow['password_hash'] as String;

    // Проверяем пароль
    if (!DBCrypt().checkpw(password, storedHash)) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Неверный логин или пароль'},
      );
    }

    final userId = userRow['id'] as String;
    final role = userRow['role'] as String;

    // Создаем JWT токен с ролью
    final jwt = JWT(
      {
        'userId': userId,
        'role': role,
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );

    // Подписываем токен и устанавливаем срок действия (например, 7 дней)
    final token = jwt.sign(
      SecretKey(Config.jwtSecret),
      expiresIn: const Duration(days: 7),
    );

    // Возвращаем только токен
    return Response.json(body: {'token': token});
    
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Внутренняя ошибка сервера: $e'},
    );
  }
}


/*
--- СТАРЫЙ КОД (ЗАКОММЕНТИРОВАН ДЛЯ СРАВНЕНИЯ) ---

import 'package:back_garson/application/services/waiter_service.dart';
import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/data/repositories/waiter_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final pool = context.read<Pool<void>>();
  final service = WaiterService(WaiterRepositoryImpl(pool));
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final username = body['username'] as String?;
    final password = body['password'] as String?;
    final restaurantId = body['restaurantId'] as String?;

    if (username == null || password == null || restaurantId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields'},
      );
    }

    final waiter = await service.signIn(username, password, restaurantId);
    final waiterModel = waiter as WaiterModel;
    return Response.json(
      body: {
        'waiter': waiterModel.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication failed: $e'},
    );
  }
}

*/