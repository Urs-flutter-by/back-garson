import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:back_garson/presentation/middleware/subscription_status_middleware.dart';
import 'package:dart_frog/dart_frog.dart';

/// Этот middleware применяется ко всем маршрутам внутри директории /users.
Handler middleware(Handler handler) {
  // Используем ту же самую цепочку защиты.
  return handler
      .use(subscriptionStatusMiddleware())
      .use(authenticationMiddleware());
}
