import 'dart:io';

import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:back_garson/presentation/middleware/subscription_status_middleware.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

// Инициализация источника БД (без изменений)
final _dbSource = DatabaseSource.instance..initialize();

// --- Логика логгера (без изменений) ---
bool _loggerInitialized = false;

void _configureLogger() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  final logFile = File('log/app.log');
  final fileSink = logFile.openSync(mode: FileMode.append);

  Logger.root.onRecord.listen((record) {
    final message =
        '${record.time}: ${record.level.name}: ${record.loggerName}: '
        '${record.message}';

    // ignore: avoid_print
    print(message);
    fileSink.writeStringSync('$message\n');

    if (record.error != null) {
      final errorMessage = '  Error: ${record.error}';
      // ignore: avoid_print
      print(errorMessage);
      fileSink.writeStringSync('$errorMessage\n');
    }
    if (record.stackTrace != null) {
      final stackTraceMessage = '  Stack Trace: ${record.stackTrace}';
      // ignore: avoid_print
      print(stackTraceMessage);
      fileSink.writeStringSync('$stackTraceMessage\n');
    }
  });
}

// --- CORS заголовки (без изменений) ---
const _corsHeaders = {
  'Access-Control-Allow-Origin':
      '*', // In production, restrict this to your frontend's domain.
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
};


// --- ОСНОВНОЙ MIDDLEWARE ---
Handler middleware(Handler handler) {
  // Создаем цепочку middleware.
  // .use() применяет обработчики в обратном порядке (последний .use() -> первый).
  final chainedHandler = handler
      .use(subscriptionStatusMiddleware()) // 3. Проверка подписки
      .use(authenticationMiddleware());   // 2. Проверка токена

  // Возвращаем итоговый обработчик, который включает в себя
  // существующую логику (логгер, CORS, провайдер БД).
  return (context) async {
    // 1. Инициализация логгера
    if (!_loggerInitialized) {
      _configureLogger();
      _loggerInitialized = true;
    }

    // Внедряем пул БД в контекст
    final updatedContext = context.provide<Pool<void>>(() => _dbSource.pool);

    // Обработка CORS
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    // Вызываем нашу новую цепочку, которая включает аутентификацию и проверку подписки
    final response = await chainedHandler(updatedContext);

    // Добавляем CORS заголовки к финальному ответу
    return response.copyWith(
      headers: {
        ...response.headers,
        ..._corsHeaders,
      },
    );
  };
}