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

/// Configures the root logger to print formatted messages to the console.
void _configureLogger() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.time}: ${record.level.name}: ${record.loggerName}: '
      '${record.message}',
    );
    if (record.error != null) {
      // ignore: avoid_print
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('  Stack Trace: ${record.stackTrace}');
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