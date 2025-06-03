import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/restaurant_themes.dart';
import 'package:back_garson/domain/repositories/restaurant_theme_repository.dart';

class RestaurantThemeRepositoryImpl implements RestaurantThemeRepository {
  final DatabaseSource database;

  RestaurantThemeRepositoryImpl(this.database);

  @override
  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId) async {
    final conn = await database.connection;
    try {
      final result = await conn.execute(
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

      return RestaurantThemeModel.fromJson({
        'id': result[0][0]! as String,
        'restaurant_id': result[0][1]! as String,
        'theme_colors': result[0][2] ?? {},
        'fonts': result[0][3] ?? {},
        'images': result[0][4] ?? {},
      });
    } finally {
      await conn.close();
    }
  }
}