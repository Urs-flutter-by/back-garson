import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/data/models/menu_model.dart';
import 'package:back_garson/data/repositories/menu_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool>();
  final menuService = MenuService(MenuRepositoryImpl(pool));

  try {
    final restaurantId = context.request.uri.queryParameters['restaurantId'];
    if (restaurantId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'restaurantId is required'},
      );
    }

    final menu = await menuService.getMenuByRestaurantId(restaurantId);
    final menuModel = menu as MenuModel;
    return Response.json(body: menuModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 500, // Use 500 for internal server errors
      body: {'error': 'Failed to get menu: $e'},
    );
  }
}