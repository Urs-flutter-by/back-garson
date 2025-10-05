// lib/domain/repositories/hall_repository.dart
import 'package:back_garson/data/models/hall_model.dart';

abstract class HallRepository {
  Future<List<HallModel>> getHallsByRestaurantId(String restaurantId);
}