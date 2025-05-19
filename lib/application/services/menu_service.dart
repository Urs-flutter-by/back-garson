import 'package:back_garson/domain/entities/menu.dart';
import 'package:back_garson/domain/repositories/menu_repository.dart';

class MenuService {
  MenuService(this.repository);

  final MenuRepository repository;

  Future<Menu> getMenuByRestaurantId(String restaurantId) async {
    return repository.getMenuByRestaurantId(restaurantId);
  }
}
