import 'dart:io';

import 'package:back_garson/data/sources/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

// Initialize the database source once, globally.
// The ..initialize() cascade notation calls the initialize
// method on the new instance.
final _dbSource = DatabaseSource.instance..initialize();

// Flag to ensure logger configuration runs only once.
bool _loggerInitialized = false;

/// Configures the root logger to print formatted messages to the console and
/// write them to a log file.
void _configureLogger() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;

  // Create a file sink to append log messages to a file.
  // Note: The sink is not explicitly closed. In a server environment, the
  // application runs continuously, and a graceful shutdown hook to close
  // resources like this might not be readily available in a simple setup.
  // The OS will handle closing the file when the process terminates.
  final logFile = File('log/app.log');
  // Use a synchronous file sink to prevent issues with async operations
  // in a synchronous listener.
  final fileSink = logFile.openSync(mode: FileMode.append);

  Logger.root.onRecord.listen((record) {
    final message =
        '${record.time}: ${record.level.name}: ${record.loggerName}: '
            '${record.message}';

    // Print to console.
    // ignore: avoid_print
    print(message);
    // Write to file synchronously.
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

Handler middleware(Handler handler) {
  return (context) async {
    // Configure logger once when the first request comes in.
    if (!_loggerInitialized) {
      _configureLogger();
      _loggerInitialized = true;
    }

    // Provide the single global pool instance to the request context.
    final updatedContext = context.provide<Pool<void>>(() => _dbSource.pool);

    // Handle OPTIONS requests for CORS preflight.
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    final response = await handler(updatedContext);

    // Add CORS headers to the actual response.
    return response.copyWith(
      headers: {
        ...response.headers,
        ..._corsHeaders,
      },
    );
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin':
      '*', // In production, restrict this to your frontend's domain.
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
};
