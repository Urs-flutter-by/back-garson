import 'package:back_garson/domain/entities/restaurant_themes.dart';

/// Абстрактный репозиторий для работы с темами ресторанов.
///
/// Определяет контракт для получения данных о темах ресторанов.
// ignore: one_member_abstracts
abstract class RestaurantThemeRepository {
  /// Получает тему оформления для указанного ресторана [restaurantId].
  ///
  /// Возвращает [Future] с объектом [RestaurantTheme].
  Future<RestaurantTheme> getRestaurantThemeById(String restaurantId);
}
