import 'package:back_garson/domain/entities/restaurant.dart';

/// Абстрактный репозиторий для работы с ресторанами.
///
/// Определяет контракт для получения данных о ресторанах.
// ignore: one_member_abstracts
abstract class RestaurantRepository {
  /// Получает информацию о ресторане по его [restaurantId].
  ///
  /// Возвращает [Future] с объектом [Restaurant].
  Future<Restaurant> getRestaurantById(String restaurantId);
}
