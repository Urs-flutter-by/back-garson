import 'dart:io';

import 'package:back_garson/application/services/permission_service.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:dart_frog/dart_frog.dart';

///3. `AuthorizationMiddleware`: Проверяет, есть ли у аутентифицированного
///пользователя право на совершение конкретного действия.
/// Создает Middleware для проверки авторизации (прав доступа).
///
/// Принимает [permissionKey] - ключ разрешения, необходимый для доступа к ресурсу.
Middleware authorizationMiddleware(String permissionKey) {
  return (handler) {
    return (context) {
      // Пытаемся прочитать информацию о пользователе из контекста.
      // Предполагается, что authenticationMiddleware уже отработал до этого.
      final payload = context.read<AuthPayload?>();

      // Если данных о пользователе нет, значит, он не аутентифицирован.
      if (payload == null) {
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Пользователь не аутентифицирован',
        );
      }

      // Проверяем права через наш сервис.
      final hasAccess = PermissionService.instance.hasPermission(
        payload.role,
        permissionKey,
      );

      // Если права есть, передаем управление следующему обработчику.
      if (hasAccess) {
        return handler(context);
      }

      // Если прав нет, возвращаем ошибку 403 Forbidden.
      return Response(
        statusCode: HttpStatus.forbidden,
        body: 'Доступ запрещен: недостаточно прав',
      );
    };
  };
}
