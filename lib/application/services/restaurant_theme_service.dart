import 'package:back_garson/domain/entities/restaurant_themes.dart';
import 'package:back_garson/domain/repositories/restaurant_theme_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с темами ресторанов.
class RestaurantThemeService {
  /// Создает экземпляр [RestaurantThemeService].
  ///
  /// Требует репозиторий [RestaurantThemeRepository], который реализует
  /// интерфейс из `lib/domain/repositories/restaurant_theme_repository.dart`.
  RestaurantThemeService(this.repository);

  /// Репозиторий для доступа к данным о темах ресторанов.
  final RestaurantThemeRepository repository;

  /// Получает тему для указанного ресторана [restaurantId].
  ///
  /// Возвращает [Future] с сущностью [RestaurantTheme]
  /// из `lib/domain/entities/restaurant_themes.dart`.
  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId) async {
    return repository.getRestaurantThemeById(restaurantId);
  }
}
