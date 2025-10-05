import 'package:back_garson/application/services/hall_service.dart';
import 'package:back_garson/data/models/shift_model.dart';
import 'package:back_garson/domain/repositories/shift_repository.dart';
import 'package:postgres/postgres.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final Pool pool;
  final HallService hallService;

  ShiftRepositoryImpl(this.pool, this.hallService);

  @override
  Future<ShiftModel> checkShift(String waiterId) async {
    try {
      return await pool.withConnection((conn) async {
        print('checkShift: using connection for waiterId: $waiterId');
        final result = await conn.execute(
          r'''
          SELECT id, waiter_id, restaurant_id, opened_at, closed_at, is_active
          FROM shifts
          WHERE waiter_id = $1 AND is_active = TRUE
          ORDER BY opened_at DESC
          LIMIT 1
          ''',
          parameters: [waiterId],
        );

        if (result.isEmpty) {
          print('checkShift: смена не найдена');
          return ShiftModel(
            id: '',
            waiterId: waiterId,
            restaurantId: '',
            openedAt: null,
            closedAt: null,
            isActive: false,
            halls: [],
          );
        }

        final shift = result[0];
        final openedAt = shift[3] as DateTime?;
        final now = DateTime.now();
        final restaurantId = shift[2] as String;

        if (openedAt != null) {
          final hoursSinceOpened = now.difference(openedAt).inHours;
          if (hoursSinceOpened > 10) {
            print('checkShift: смена устарела, закрываем (id: ${shift[0]})');
            await conn.execute(
              r'''
              UPDATE shifts
              SET is_active = FALSE, closed_at = $1
              WHERE id = $2
              ''',
              parameters: [now.toIso8601String(), shift[0]],
            );
            return ShiftModel(
              id: '',
              waiterId: waiterId,
              restaurantId: '',
              openedAt: null,
              closedAt: null,
              isActive: false,
              halls: [],
            );
          }
        }

        // Получаем залы для ресторана
        final halls = await hallService.getHallsByRestaurantId(restaurantId);

        print('checkShift: найдена активная смена (id: ${shift[0]})');
        return ShiftModel(
          id: shift[0] as String,
          waiterId: shift[1] as String,
          restaurantId: restaurantId,
          openedAt: openedAt,
          closedAt: shift[4] as DateTime?,
          isActive: shift[5] as bool,
          halls: halls,
        );
      });
    } catch (e, stackTrace) {
      print('checkShift: ошибка: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<ShiftModel> openShift(String waiterId, String restaurantId) async {
    try {
      return await pool.withConnection((conn) async {
        print(
            'openShift: using connection for waiterId: $waiterId, restaurantId: $restaurantId');
        final result = await conn.execute(
          r'''
          SELECT id, waiter_id, restaurant_id, opened_at, closed_at, is_active
          FROM shifts
          WHERE waiter_id = $1 AND is_active = TRUE
          ORDER BY opened_at DESC
          LIMIT 1
          ''',
          parameters: [waiterId],
        );

        if (result.isNotEmpty) {
          final shift = result[0];
          final openedAt = shift[3] as DateTime?;
          final now = DateTime.now();

          if (openedAt != null) {
            final hoursSinceOpened = now.difference(openedAt).inHours;
            if (hoursSinceOpened > 10) {
              print('openShift: смена устарела, закрываем (id: ${shift[0]})');
              await conn.execute(
                r'''
                UPDATE shifts
                SET is_active = FALSE, closed_at = $1
                WHERE id = $2
                ''',
                parameters: [now.toIso8601String(), shift[0]],
              );
            } else {
              print('openShift: найдена активная смена (id: ${shift[0]})');
              final halls = await hallService.getHallsByRestaurantId(restaurantId);
              return ShiftModel(
                id: shift[0] as String,
                waiterId: shift[1] as String,
                restaurantId: shift[2] as String,
                openedAt: openedAt,
                closedAt: shift[4] as DateTime?,
                isActive: shift[5] as bool,
                halls: halls,
              );
            }
          }
        }

        print('openShift: создаём новую смену');
        final now = DateTime.now();
        final insertResult = await conn.execute(
          r'''
          INSERT INTO shifts (waiter_id, restaurant_id, opened_at, is_active)
          VALUES ($1, $2, $3, TRUE)
          RETURNING id, waiter_id, restaurant_id, opened_at, is_active
          ''',
          parameters: [waiterId, restaurantId, now.toIso8601String()],
        );

        print('openShift: смена создана (id: ${insertResult[0][0]})');
        final shift = insertResult[0];
        final halls = await hallService.getHallsByRestaurantId(restaurantId);
        return ShiftModel(
          id: shift[0] as String,
          waiterId: shift[1] as String,
          restaurantId: shift[2] as String,
          openedAt: shift[3] as DateTime,
          closedAt: null,
          isActive: shift[4] as bool,
          halls: halls,
        );
      });
    } catch (e, stackTrace) {
      print('openShift: ошибка: $e\n$stackTrace');
      rethrow;
    }
  }
}