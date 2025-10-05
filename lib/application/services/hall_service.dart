// lib/application/services/hall_service.dart
import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/domain/repositories/hall_repository.dart';

class HallService {
  final HallRepository repository;

  HallService(this.repository);

  Future<List<HallModel>> getHallsByRestaurantId(String restaurantId) async {
    return repository.getHallsByRestaurantId(restaurantId);
  }
}