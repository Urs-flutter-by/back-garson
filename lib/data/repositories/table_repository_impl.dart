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
    int tableId;
    try {
      tableId = int.parse(id);
    } catch (e) {
      throw Exception('Invalid table ID: $id must be a valid integer');
    }

    final conn = await database.connection;
    final result = await conn.execute(
      r'''
      SELECT t.id, t.status, t.capacity, t.number, r.name as restaurantName
      FROM tables t
      JOIN restaurants r ON t.restaurant_id = r.id
      WHERE t.id = $1
      ''',
      parameters: [tableId],
    );

    if (result.isEmpty) {
      throw Exception('Table not found');
    }

    return TableModel.fromJson({
      'id': result[0][0].toString(),
      'status': result[0][1],
      'capacity': result[0][2],
      'number': result[0][3],
      'restaurantName': result[0][4], // Меняем ключ на restaurantName
    });
  }
}