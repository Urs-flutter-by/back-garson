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
      String? token;

      // Способ 1: Ищем токен в заголовке Authorization (для мобильных клиентов)
      final authHeader =
          context.request.headers[HttpHeaders.authorizationHeader];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
      }

      // Способ 2: Если в заголовке нет, ищем в query-параметрах (для веб-клиентов)
      if (token == null) {
        token = context.request.uri.queryParameters['token'];
      }

      // Если токен не найден ни одним из способов, возвращаем ошибку
      if (token == null) {
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Токен аутентификации не предоставлен',
        );
      }

      try {
        // Проверяем токен: подпись и срок действия
        final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        final role = payload['role'] as String?;

        if (role == null) {
          // Используем стандартное исключение
          throw Exception('В токене отсутствует роль (role)');
        }

        AuthPayload authPayload;
        if (role == 'CUSTOMER') {
          authPayload = AuthPayload(
            role: role,
            tableId: payload['tableId'] as String?,
            restaurantId: payload['restaurantId'] as String?,
          );
        } else {
          authPayload = AuthPayload(
            role: role,
            userId: payload['userId'] as String?,
          );
        }

        // Внедряем информацию о пользователе в контекст запроса,
        // чтобы она была доступна в следующих обработчиках.
        final newContext = context.provide<AuthPayload>(() => authPayload);

        // Передаем управление следующему обработчику в цепочке
        return handler(newContext);
      } catch (e) {
        // Этот блок отлавливает ЛЮБУЮ ошибку при проверке токена
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Невалидный или истекший токен',
        );
      }
    };
  };
}
