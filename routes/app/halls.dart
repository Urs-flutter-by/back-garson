import 'package:back_garson/application/services/hall_service.dart';
import 'package:back_garson/data/repositories/hall_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final pool = context.read<Pool<void>>();
  final service = HallService(HallRepositoryImpl(pool));
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final restaurantId = body['restaurantId'] as String?;
    if (restaurantId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing restaurantId'},
      );
    }

    final halls = await service.getHallsByRestaurantId(restaurantId);
    return Response.json(
      body: {
        'success': true,
        'halls': halls.map((h) => h.toJson()).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to fetch halls: $e'},
    );
  }
}