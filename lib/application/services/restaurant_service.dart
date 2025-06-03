import 'package:back_garson/domain/entities/restaurant.dart';
import 'package:back_garson/domain/repositories/restaurant_repository.dart';


class RestaurantService {
  RestaurantService(this.repository);

  final RestaurantRepository repository;

  Future<Restaurant> getRestaurantById(String restaurantId) async {
    return repository.getRestaurantById(restaurantId);
  }
}