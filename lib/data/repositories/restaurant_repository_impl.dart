import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/domain/entities/restaurant.dart';
import 'package:back_garson/domain/repositories/restaurant_repository.dart';
import 'package:postgres/postgres.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final Pool pool;

  RestaurantRepositoryImpl(this.pool);

  @override
  Future<Restaurant> getRestaurantById(String restaurantId) async {
    try {
      final result = await pool.execute(
        r'''
        SELECT id, name, description, self_order_discount
        FROM restaurants
        WHERE id = $1
        ''',
        parameters: [restaurantId],
      );

      if (result.isEmpty) {
        throw Exception('Restaurant not found');
      }

      final row = result.first;
      return RestaurantModel.fromJson({
        'id': row[0] as String,
        'name': row[1] as String,
        'description': row[2] as String? ?? '',
        'self_order_discount': row[3] as int? ?? 0,
      });
    } catch (e) {
      print('Error in getRestaurantById: $e');
      rethrow;
    }
  }
}