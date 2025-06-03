import 'package:back_garson/domain/entities/restaurant_themes.dart';
import 'package:back_garson/domain/repositories/restaurant_theme_repository.dart';

class RestaurantThemeService {
  RestaurantThemeService(this.repository);

  final RestaurantThemeRepository repository;

  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId) async {
    return repository.getRestaurantThemeById(restaurantId);
  }
}
