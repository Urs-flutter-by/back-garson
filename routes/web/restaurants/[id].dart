
import 'package:back_garson/application/services/restaurant_service.dart';
import 'package:back_garson/data/models/restaurant_model.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final service = context.read<RestaurantService>();

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
