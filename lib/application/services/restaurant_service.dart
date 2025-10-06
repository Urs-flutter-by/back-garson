import 'package:back_garson/domain/entities/restaurant.dart';
import 'package:back_garson/domain/repositories/restaurant_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с ресторанами.
class RestaurantService {
  /// Создает экземпляр [RestaurantService].
  ///
  /// Требует репозиторий [RestaurantRepository], который реализует
  /// интерфейс из `lib/domain/repositories/restaurant_repository.dart`.
  RestaurantService(this.repository);

  /// Репозиторий для доступа к данным о ресторанах.
  final RestaurantRepository repository;

  /// Получает информацию о ресторане по его [restaurantId].
  ///
  /// Возвращает [Future] с сущностью [Restaurant]
  /// из `lib/domain/entities/restaurant.dart`.
  Future<Restaurant> getRestaurantById(String restaurantId) async {
    return repository.getRestaurantById(restaurantId);
  }
}
