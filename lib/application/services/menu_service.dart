import 'package:back_garson/domain/entities/menu.dart';
import 'package:back_garson/domain/repositories/menu_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с меню.
class MenuService {
  /// Создает экземпляр [MenuService].
  ///
  /// Требует репозиторий [MenuRepository], который реализует
  /// интерфейс из `lib/domain/repositories/menu_repository.dart`.
  MenuService(this.repository);

  /// Репозиторий для доступа к данным о меню.
  final MenuRepository repository;

  /// Получает меню для указанного ресторана [restaurantId].
  ///
  /// Возвращает [Future] с сущностью [Menu]
  /// из `lib/domain/entities/menu.dart`.
  Future<Menu> getMenuByRestaurantId(String restaurantId) async {
    return repository.getMenuByRestaurantId(restaurantId);
  }
}
