import 'package:back_garson/utils/config.dart';
import 'package:postgres/postgres.dart';

/// Глобальный класс для управления пулом соединений с базой данных.
/// Использует паттерн Singleton, чтобы экземпляр был один на все приложение.
class DatabaseSource {
  // Приватный конструктор
  DatabaseSource._();

  // Статический экземпляр класса (Singleton)
  static final DatabaseSource instance = DatabaseSource._();

  late final Pool<void> _pool;
  bool _isInitialized = false;

  /// Инициализирует пул соединений.
  /// Этот метод нужно вызвать один раз при старте сервера.
  void initialize() {
    if (_isInitialized) return;

    final endpoint = Endpoint(
      host: Config.dbHost,
      port: Config.dbPort,
      database: Config.dbName,
      username: Config.dbUser,
      password: Config.dbPassword,
    );

    _pool = Pool.withEndpoints(
      [endpoint],
      settings: const PoolSettings(
        // Установите максимальное количество одновременных соединений
        maxConnectionCount: 10,
      ),
    );
    _isInitialized = true;
  }

  /// Предоставляет доступ к пулу соединений.
  Pool<void> get pool {
    if (!_isInitialized) {
      throw StateError('DatabaseSource не инициализирован. Вызовите initialize() при старте приложения.');
    }
    return _pool;
  }

  /// Закрывает все соединения в пуле.
  /// Этот метод нужно вызвать при graceful shutdown сервера.
  Future<void> close() async {
    if (_isInitialized) {
      await _pool.close();
      _isInitialized = false;
    }
  }
}
