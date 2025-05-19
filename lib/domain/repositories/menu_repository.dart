import 'package:back_garson/domain/entities/menu.dart';


abstract class MenuRepository {
  Future<Menu> getMenuByRestaurantId(String restaurantId);
}