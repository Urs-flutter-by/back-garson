/// Конфигурация для подключения к БД
class Config {
  /// хост
  static const String dbHost = 'localhost';

  /// порт
  static const int dbPort = 5432;

  /// имя базы
  static const String dbName = 'el_garson';

  /// имя пользователя
  static const String dbUser = 'postgres';

  /// пароль для подключения к БД
  static const String dbPassword = 'Art123'; // Замени на свой пароль

  /// Секретный ключ для подписи JWT-токенов.
  /// ВАЖНО: В продакшене замените на длинный, случайный ключ
  /// и загружайте его из переменных окружения, а не храните в коде.
  static const String jwtSecret = 'your-super-secret-and-long-jwt-key';
}
