import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:back_garson/domain/entities/restaurant_themes.dart';
import 'package:back_garson/domain/repositories/restaurant_theme_repository.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

/// Реализация репозитория для работы с темами ресторанов.
///
/// Реализует интерфейс [RestaurantThemeRepository] из `lib/domain/repositories/restaurant_theme_repository.dart`.
class RestaurantThemeRepositoryImpl implements RestaurantThemeRepository {
  /// Создает экземпляр [RestaurantThemeRepositoryImpl].
  ///
  /// Требует пул соединений [pool].
  RestaurantThemeRepositoryImpl(this.pool);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  static final _log = Logger('RestaurantThemeRepositoryImpl');

  @override

  /// Получает тему оформления для указанного ресторана [restaurantId].
  ///
  /// В случае ошибки или если тема не найдена, выбрасывает исключение.
  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId) async {
    try {
      final result = await pool.execute(
        r'''
        SELECT id, restaurant_id, theme_colors, fonts, images
        FROM restaurant_themes
        WHERE restaurant_id = $1
        ''',
        parameters: [restaurantId],
      );

      if (result.isEmpty) {
        throw Exception('Restaurant theme not found');
      }

      final row = result.first;
      return RestaurantThemeModel.fromJson({
        'id': row[0]! as String,
        'restaurant_id': row[1]! as String,
        'theme_colors': row[2] ?? {},
        'fonts': row[3] ?? {},
        'images': row[4] ?? {},
      });
    } catch (e, st) {
      _log.severe('Error in getRestaurantThemeById', e, st);
      rethrow;
    }
  }
}
