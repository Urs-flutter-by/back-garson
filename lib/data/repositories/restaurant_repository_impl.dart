import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/domain/entities/restaurant.dart';
import 'package:back_garson/domain/repositories/restaurant_repository.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

/// Реализация репозитория для работы с ресторанами.
///
/// Реализует интерфейс [RestaurantRepository] из `lib/domain/repositories/restaurant_repository.dart`.
class RestaurantRepositoryImpl implements RestaurantRepository {
  /// Создает экземпляр [RestaurantRepositoryImpl].
  ///
  /// Требует пул соединений [pool].
  RestaurantRepositoryImpl(this.pool);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  static final _log = Logger('RestaurantRepositoryImpl');

  @override

  /// Получает информацию о ресторане по его [restaurantId].
  ///
  /// В случае ошибки или если ресторан не найден, выбрасывает исключение.
  Future<Restaurant> getRestaurantById(String restaurantId) async {
    try {
      final result = await pool.execute(
        r'''
        SELECT id, name, description, self_order_discount
        FROM restaurants
        WHERE id = $1
        ''',
        parameters: [restaurantId],
      );

      if (result.isEmpty) {
        throw Exception('Restaurant not found');
      }

      final row = result.first;
      return RestaurantModel.fromJson({
        'id': row[0]! as String,
        'name': row[1]! as String,
        'description': row[2] as String? ?? '',
        'self_order_discount': row[3] as int? ?? 0,
      });
    } catch (e, st) {
      _log.severe('Error in getRestaurantById', e, st);
      rethrow;
    }
  }
}
