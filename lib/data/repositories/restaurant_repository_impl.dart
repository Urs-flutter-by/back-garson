import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/restaurant.dart';
import 'package:back_garson/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final DatabaseSource database;

  RestaurantRepositoryImpl(this.database);

  @override
  Future<Restaurant> getRestaurantById(String restaurantId) async {
    final conn = await database.connection;
    try {
      final result = await conn.execute(
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

      return RestaurantModel.fromJson({
        'id': result[0][0] as String,
        'name': result[0][1] as String,
        'description': result[0][2] as String? ?? '',
        'self_order_discount': result[0][3] as int? ?? 0,
      });
    } finally {
      await conn.close();
    }
  }
}