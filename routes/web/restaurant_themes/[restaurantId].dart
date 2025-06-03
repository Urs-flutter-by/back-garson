import 'package:back_garson/application/services/restaurant_theme_service.dart';
import 'package:back_garson/data/models/restaurant_themes_model.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String restaurantId) async {
  final service = context.read<RestaurantThemeService>();

  try {
    final theme = await service.getRestaurantThemeById(restaurantId);
    final themeModel = theme as RestaurantThemeModel;
    return Response.json(body: themeModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Restaurant theme not found: $e'},
    );
  }
}