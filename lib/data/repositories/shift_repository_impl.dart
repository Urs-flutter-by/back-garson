import 'package:back_garson/application/services/hall_service.dart';
import 'package:back_garson/data/models/shift_model.dart';
import 'package:back_garson/domain/repositories/shift_repository.dart';
import 'package:postgres/postgres.dart';

/// Реализация репозитория для работы со сменами.
///
/// Реализует интерфейс [ShiftRepository] из
/// `lib/domain/repositories/shift_repository.dart`.
class ShiftRepositoryImpl implements ShiftRepository {
  /// Создает экземпляр [ShiftRepositoryImpl].
  ///
  /// Требует пул соединений [pool] и сервис залов [hallService].
  ShiftRepositoryImpl(this.pool, this.hallService);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  /// Сервис для получения информации о залах.
  final HallService hallService;

  @override

  /// Проверяет наличие активной смены для официанта.
  ///
  /// Принимает [waiterId] официанта.
  /// Возвращает [Future] с объектом [ShiftModel],
  /// представляющим активную смену,
  /// или пустой [ShiftModel], если активная смена не найдена или устарела.
  Future<ShiftModel> checkShift(String waiterId) async {
    try {
      return await pool.withConnection((conn) async {
        // print('checkShift: using connection for waiterId: $waiterId');
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
          // print('checkShift: смена не найдена');
          return ShiftModel(
            id: '',
            waiterId: waiterId,
            restaurantId: '',
            isActive: false,
            halls: [],
          );
        }

        final shift = result[0];
        final openedAt = shift[3] as DateTime?;
        final now = DateTime.now();
        final restaurantId = shift[2]! as String;

        if (openedAt != null) {
          final hoursSinceOpened = now.difference(openedAt).inHours;
          if (hoursSinceOpened > 10) {
            // print('checkShift: смена устарела, закрываем (id: ${shift[0]})');
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
              isActive: false,
              halls: [],
            );
          }
        }

                      final halls = await hallService
                          .getHallsByRestaurantId(restaurantId);
        // print('checkShift: найдена активная смена (id: ${shift[0]})');
        return ShiftModel(
          id: shift[0]! as String,
          waiterId: shift[1]! as String,
          restaurantId: restaurantId,
          openedAt: openedAt,
          closedAt: shift[4] as DateTime?,
          isActive: shift[5]! as bool,
          halls: halls,
        );
      });
    } catch (e) {
      // print('checkShift: ошибка: $e');
      rethrow;
    }
  }

  @override

  /// Открывает новую смену для официанта.
  ///
  /// Принимает [waiterId] официанта и [restaurantId] ресторана.
  /// Возвращает [Future] с объектом [ShiftModel],
  /// представляющим открытую смену.
  /// В случае ошибки выбрасывает исключение.
  Future<ShiftModel> openShift(String waiterId, String restaurantId) async {
    try {
      return await pool.withConnection((conn) async {
        // print(
        //   'openShift: using connection for waiterId: $waiterId,
        //   restaurantId: $restaurantId',
        // );
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
              // print('openShift: смена устарела,
              // закрываем (id: ${shift[0]})');
              await conn.execute(
                r'''
                UPDATE shifts
                SET is_active = FALSE, closed_at = $1
                WHERE id = $2
                ''',
                parameters: [now.toIso8601String(), shift[0]],
              );
            } else {
              // print('openShift: найдена активная смена (id: ${shift[0]})');
              final halls = await hallService
                  .getHallsByRestaurantId(restaurantId);
              return ShiftModel(
                id: shift[0]! as String,
                waiterId: shift[1]! as String,
                restaurantId: shift[2]! as String,
                openedAt: openedAt,
                closedAt: shift[4] as DateTime?,
                isActive: shift[5]! as bool,
                halls: halls,
              );
            }
          }
        }

        // print('openShift: создаём новую смену');
        final now = DateTime.now();
        final insertResult = await conn.execute(
          r'''
          INSERT INTO shifts (waiter_id, restaurant_id, opened_at, is_active)
          VALUES ($1, $2, $3, TRUE)
          RETURNING id, waiter_id, restaurant_id, opened_at, is_active
          ''',
          parameters: [waiterId, restaurantId, now.toIso8601String()],
        );

        // print('openShift: смена создана (id: ${insertResult[0][0]})');
        final shift = insertResult[0];
        final halls = await hallService.getHallsByRestaurantId(restaurantId);
        return ShiftModel(
          id: shift[0]! as String,
          waiterId: shift[1]! as String,
          restaurantId: shift[2]! as String,
          openedAt: shift[3]! as DateTime,
          isActive: shift[4]! as bool,
          halls: halls,
        );
      });
    } catch (e) {
      // print('openShift: ошибка: $e');
      rethrow;
    }
  }
}
