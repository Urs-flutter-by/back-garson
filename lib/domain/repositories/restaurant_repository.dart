import 'package:back_garson/domain/entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<Restaurant> getRestaurantById(String restaurantId);
}