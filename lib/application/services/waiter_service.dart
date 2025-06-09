// lib/application/services/waiter_service.dart
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';

class WaiterService {
  final WaiterRepository repository;

  WaiterService(this.repository);

  Future<Waiter> signIn(
      String username, String password, String restaurantId) async {
    return repository.signIn(username, password, restaurantId);
  }
}
