import 'package:back_garson/domain/entities/waiter.dart';

abstract class WaiterRepository {
  Future<Waiter> signIn(String id, String username, String restaurantId);
}
