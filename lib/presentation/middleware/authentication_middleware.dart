import 'dart:io';

import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

///1. `AuthenticationMiddleware`: Проверяет,
///что пользователь прислал валидный токен. Переходит к `PermissionService`
/// Middleware для проверки JWT-токена и аутентификации пользователя.
Middleware authenticationMiddleware() {
  return (handler) {
    return (context) {
      // Получаем заголовок Authorization
      final authHeader =
          context.request.headers[HttpHeaders.authorizationHeader];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        // Если заголовка нет или он некорректный, возвращаем ошибку 401
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Отсутствует или неверный токен аутентификации',
        );
      }

      // Извлекаем сам токен
      final token = authHeader.substring(7);

      try {
        // Проверяем токен: подпись и срок действия
        final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        // Создаем объект с данными пользователя из токена
        final authPayload = AuthPayload(
          userId: payload['userId'] as String,
          role: payload['role'] as String,
        );

        // Внедряем информацию о пользователе в контекст запроса,
        // чтобы она была доступна в следующих обработчиках.
        final newContext = context.provide<AuthPayload>(() => authPayload);

        // Передаем управление следующему обработчику в цепочке
        return handler(newContext);
      } catch (e) {
        // Этот блок отлавливает ЛЮБУЮ ошибку при проверке токена
        // (неверная подпись, истекший срок, неверный формат и т.д.)
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Невалидный или истекший токен',
        );
      }
    };
  };
}
