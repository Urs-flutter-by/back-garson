import 'package:back_garson/domain/entities/restaurant_themes.dart';

abstract class RestaurantThemeRepository {
  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId);
}