import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:back_garson/domain/entities/restaurant_themes.dart';
import 'package:back_garson/domain/repositories/restaurant_theme_repository.dart';
import 'package:postgres/postgres.dart';

class RestaurantThemeRepositoryImpl implements RestaurantThemeRepository {
  final Pool pool;

  RestaurantThemeRepositoryImpl(this.pool);

  @override
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
    } catch (e) {
      print('Error in getRestaurantThemeById: $e');
      rethrow;
    }
  }
}