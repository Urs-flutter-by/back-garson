import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:back_garson/presentation/middleware/subscription_status_middleware.dart';
import 'package:dart_frog/dart_frog.dart';

/// Этот middleware применяется ко всем маршрутам внутри директории /app.
Handler middleware(Handler handler) {
  // Создаем цепочку middleware для защиты.
  // .use() применяет обработчики в обратном порядке (последний -> первый).
  return handler
      .use(subscriptionStatusMiddleware()) // Выполняется вторым
      .use(authenticationMiddleware());   // Выполняется первым
}
