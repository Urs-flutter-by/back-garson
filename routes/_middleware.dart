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
  // В глобальном middleware оставляем только то, что нужно всем: 
  // логгер, CORS и провайдер пула БД.
  final newHandler = handler.use(provider<Pool<void>>((_) => _dbSource.pool));

  return (context) async {
    // Конфигурация логгера.
    if (!_loggerInitialized) {
      _configureLogger();
      _loggerInitialized = true;
    }

    // Обработка CORS.
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    // Вызываем следующий обработчик.
    final response = await newHandler(context);

    // Добавляем CORS заголовки к финальному ответу.
    return response.copyWith(
      headers: {
        ...response.headers,
        ..._corsHeaders,
      },
    );
  };
}