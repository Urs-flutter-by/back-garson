// lib/data/repositories/shift_repository_impl.dart
import 'package:back_garson/data/models/shift_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final DatabaseSource database;

  ShiftRepositoryImpl(this.database);

  @override
  Future<ShiftModel> checkShift(String waiterId) async {
    final conn = await database.connection;
    print('checkShift: соединение установлено для waiterId: $waiterId');
    try {
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
        );
      }

      final shift = result[0];
      final openedAt = shift[3] as DateTime?;
      final now = DateTime.now();

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
          );
        }
      }

      print('checkShift: найдена активная смена (id: ${shift[0]})');
      return ShiftModel(
        id: shift[0] as String,
        waiterId: shift[1] as String,
        restaurantId: shift[2] as String,
        openedAt: openedAt,
        closedAt: shift[4] as DateTime?,
        isActive: shift[5] as bool,
      );
    } finally {
      print('checkShift: закрываем соединение');
      await conn.close();
    }
  }

  @override
  Future<ShiftModel> openShift(String waiterId, String restaurantId) async {
    final conn = await database.connection;
    print('openShift: соединение установлено для waiterId: $waiterId, restaurantId: $restaurantId');
    try {
      // Проверяем существующую смену, используя то же соединение
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
            return ShiftModel(
              id: shift[0] as String,
              waiterId: shift[1] as String,
              restaurantId: shift[2] as String,
              openedAt: openedAt,
              closedAt: shift[4] as DateTime?,
              isActive: shift[5] as bool,
            );
          }
        }
      }

      // Если нет активной смены, создаём новую
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
      return ShiftModel(
        id: shift[0] as String,
        waiterId: shift[1] as String,
        restaurantId: shift[2] as String,
        openedAt: shift[3] as DateTime,
        closedAt: null,
        isActive: shift[4] as bool,
      );
    } catch (e, stackTrace) {
      print('openShift: ошибка: $e\n$stackTrace');
      rethrow; // Пробрасываем ошибку для обработки в роуте
    } finally {
      print('openShift: закрываем соединение');
      await conn.close();
    }
  }
}