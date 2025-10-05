import 'package:back_garson/application/services/restaurant_service.dart';
import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:back_garson/data/repositories/restaurant_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final pool = context.read<Pool>();
  final service = RestaurantService(RestaurantRepositoryImpl(pool));

  try {
    final restaurant = await service.getRestaurantById(id);
    final restaurantModel = restaurant as RestaurantModel;
    return Response.json(body: restaurantModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Restaurant not found: $e'},
    );
  }
}
