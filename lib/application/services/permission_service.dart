import 'package:back_garson/data/sources/database.dart';
import 'package:logging/logging.dart';

///2. `PermissionService`: Загружает и кэширует все права доступа из базы данных
/// и далее к `AuthorizationMiddleware`
/// Сервис для управления и проверки прав доступа (разрешений) ролей.
/// Использует кэширование в памяти для максимальной производительности.
class PermissionService {
  // Приватный конструктор для реализации Singleton.
  PermissionService._();

  /// Статический экземпляр класса (Singleton).
  static final PermissionService instance = PermissionService._();

  /// Кэш для хранения разрешений.
  /// Ключ - ID роли, значение - набор ключей разрешений.
  final Map<String, Set<String>> _cachedPermissions = {};

  final _log = Logger('PermissionService');

  var _isInitialized = false;

  /// Загружает все связки "роль-разрешение" из базы данных в кэш.
  /// Должен вызываться один раз при старте сервера.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _log.info('Загрузка и кэширование прав доступа...');

    final dbPool = DatabaseSource.instance.pool;
    const query = '''
      SELECT rp.role_id, p.action_key
      FROM role_permissions rp
      JOIN permissions p ON rp.permission_id = p.id;
    ''';

    // Корректный паттерн для выполнения одиночного запроса
    final result = await dbPool.withConnection(
      (connection) => connection.execute(query),
    );

    for (final row in result) {
      final map = row.toColumnMap();
      final roleId = map['role_id'] as String;
      final permissionKey = map['action_key'] as String;

      // Если для роли еще нет набора разрешений, создаем его
      _cachedPermissions.putIfAbsent(roleId, () => {});
      // Добавляем разрешение в набор
      _cachedPermissions[roleId]!.add(permissionKey);
    }

    _isInitialized = true;
    _log.info(
      'Права доступа успешно загружены. '
      'Загружено для ${_cachedPermissions.length} ролей.',
    );
  }

  /// Проверяет, имеет ли указанная роль указанное разрешение.
  /// Проверка происходит по кэшу и является очень быстрой.
  ///
  /// [role] - ID роли (например, 'ADMIN_RESTAURANT').
  /// [permissionKey] - Ключ разрешения (например, 'dish:create').
  bool hasPermission(String role, String permissionKey) {
    if (!_isInitialized) {
      _log.warning(
          'Попытка проверить права до инициализации PermissionService');
      // В зависимости от политики безопасности, можно либо запрещать все,
      // либо выбрасывать исключение.
      return false;
    }

    // Суперадмин имеет доступ ко всему по определению.
    if (role == 'SUPER_ADMIN') {
      return true;
    }

    // Получаем набор разрешений для данной роли.
    final userPermissions = _cachedPermissions[role];

    // Если у роли вообще нет разрешений, возвращаем false.
    if (userPermissions == null) {
      return false;
    }

    // Проверяем, содержит ли набор нужное разрешение.
    return userPermissions.contains(permissionKey);
  }
}
