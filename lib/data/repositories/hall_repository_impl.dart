// lib/data/repositories/hall_repository_impl.dart
import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/domain/repositories/hall_repository.dart';
import 'package:postgres/postgres.dart';

class HallRepositoryImpl implements HallRepository {
  final Pool<void> pool;

  HallRepositoryImpl(this.pool);

  @override
  Future<List<HallModel>> getHallsByRestaurantId(String restaurantId) async {
    try {
      return await pool.withConnection((connection) async {
        // Получаем залы
        final hallResult = await connection.execute(
          r'''
          SELECT id, restaurant_id, name
          FROM halls
          WHERE restaurant_id = $1
          ''',
          parameters: [restaurantId],
        );

        final halls = <HallModel>[];
        for (final row in hallResult) {
          final hallId = row[0] as String;

          // Получаем столики для каждого зала
          final tableResult = await connection.execute(
            r'''
            SELECT id, hall_id, restaurant_id, number, status, is_own, has_new_order,
                   has_guest_request, has_in_progress_order, has_in_progress_request,
                    capacity
            FROM tables
            WHERE hall_id = $1
            ''',
            parameters: [hallId],
          );

          final tables = tableResult.map((tableRow) => TableModel(
            id: tableRow[0] as String,
            hallId: tableRow[1] as String?,
            restaurantId: tableRow[2] as String,
            number: tableRow[3] as int,
            status: tableRow[4] as String,
            isOwn: tableRow[5] as bool? ?? false,
            hasNewOrder: tableRow[6] as bool? ?? false,
            hasGuestRequest: tableRow[7] as bool? ?? false,
            hasInProgressOrder: tableRow[8] as bool? ?? false,
            hasInProgressRequest: tableRow[9] as bool? ?? false,
            capacity: tableRow[10] as int,
          )).toList();

          halls.add(HallModel(
            id: hallId,
            restaurantId: row[1] as String,
            name: row[2] as String,
            tables: tables,
          ));
        }

        return halls;
      });
    } catch (e, stackTrace) {
      print('HallRepositoryImpl: ошибка: $e\n$stackTrace');
      rethrow;
    }
  }
}
