import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/domain/entities/table.dart';
import 'package:back_garson/domain/repositories/table_repository.dart';
import 'package:postgres/postgres.dart';

class TableRepositoryImpl implements TableRepository {
  final Pool pool;

  TableRepositoryImpl(this.pool);

  @override
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
    } catch (e) {
      print('Error in getTableById: $e');
      rethrow;
    }
  }
}
