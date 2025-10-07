import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/domain/entities/table.dart';
import 'package:back_garson/domain/repositories/table_repository.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

/// Реализация репозитория для работы со столами.
///
/// Реализует интерфейс [TableRepository] из `lib/domain/repositories/table_repository.dart`.
class TableRepositoryImpl implements TableRepository {
  /// Создает экземпляр [TableRepositoryImpl].
  ///
  /// Требует пул соединений [pool].
  TableRepositoryImpl(this.pool);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  static final _log = Logger('TableRepositoryImpl');

  @override

  /// Получает информацию о столе по его [id].
  ///
  /// В случае ошибки или если стол не найден, выбрасывает исключение.
  Future<Table> getTableById(String id) async {
    try {
      final result = await pool.execute(
        r'''
        SELECT t.id, t.status, t.capacity, t.number, r.id as restaurantId
        FROM tables t
        LEFT JOIN restaurants r ON t.restaurant_id = r.id
        WHERE t.id = $1
        ''',
        parameters: [id], // Передаём строку UUID
      );

      if (result.isEmpty) {
        throw Exception('Table not found');
      }

      final row = result.first;
      return TableModel.fromJson({
        'id': row[0]! as String,
        'status': row[1]! as String,
        'capacity': row[2]! as int,
        'number': row[3]! as int,
        'restaurantId': row[4]! as String,
      });
    } catch (e, st) {
      _log.severe('Error in getTableById', e, st);
      rethrow;
    }
  }
}
