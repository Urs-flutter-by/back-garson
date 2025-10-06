import 'package:back_garson/utils/config.dart';
import 'package:postgres/postgres.dart';

/// Глобальный класс для управления пулом соединений с базой данных.
/// Использует паттерн Singleton, чтобы экземпляр был один на все приложение.
class DatabaseSource {
  // Приватный конструктор
  DatabaseSource._();

  // Статический экземпляр класса (Singleton)
  static final DatabaseSource instance = DatabaseSource._();

  /// Пул соединений с базой данных.
  late final Pool<void> _pool;
  bool _isInitialized = false;

  /// Инициализирует пул соединений.
  /// Этот метод нужно вызвать один раз при старте сервера.
  void initialize() {
    if (_isInitialized) return;

    const dbUrl =
        'postgres://${Config.dbUser}:${Config.dbPassword}@${Config.dbHost}:${Config.dbPort}/${Config.dbName}?sslmode=disable&max_connection_count=10';

    _pool = Pool.withUrl(dbUrl);
    _isInitialized = true;
  }

  /// Предоставляет доступ к пулу соединений.
  Pool<void> get pool {
    if (!_isInitialized) {
      throw StateError(
          'DatabaseSource не инициализирован. Вызовите initialize()'
          ' при старте приложения.');
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
