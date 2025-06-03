import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/table.dart';
import 'package:back_garson/domain/repositories/table_repository.dart';

//Реализует интерфейс TableRepository, используя DatabaseSource
// для выполнения SQL-запросов к PostgreSQL. Здесь выполняется запрос
// к таблице tables и преобразование результата в TableModel

class TableRepositoryImpl implements TableRepository {
  final DatabaseSource database;

  TableRepositoryImpl(this.database);

  @override
  Future<Table> getTableById(String id) async {
    final conn = await database.connection;
    try {
      final result = await conn.execute(
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

      return TableModel.fromJson({
        'id': result[0][0]! as String,
        'status': result[0][1]! as String,
        'capacity': result[0][2]! as int,
        'number': result[0][3]! as int,
        'restaurantId': result[0][4]! as String,
      });
    } finally {
      await conn.close();
    }
  }
}