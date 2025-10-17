import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:back_garson/presentation/middleware/authorization_middleware.dart';
import 'package:dart_frog/dart_frog.dart';

/// Этот middleware применяется ко всем эндпоинтам внутри /orders/{id}/
Handler middleware(Handler handler) {
  return handler
      // Проверяем право на редактирование статуса заказа
      .use(authorizationMiddleware('order:status:edit'))
      // Проверяем токен
      .use(authenticationMiddleware());
}
