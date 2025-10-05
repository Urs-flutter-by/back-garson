import 'package:back_garson/application/services/waiter_service.dart';
import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/data/repositories/waiter_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final pool = context.read<Pool<void>>();
  final service = WaiterService(WaiterRepositoryImpl(pool));
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final username = body['username'] as String?;
    final password = body['password'] as String?;
    final restaurantId = body['restaurantId'] as String?;

    if (username == null || password == null || restaurantId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields'},
      );
    }

    final waiter = await service.signIn(username, password, restaurantId);
    final waiterModel = waiter as WaiterModel;
    return Response.json(body: {
      'waiter': waiterModel.toJson(),
    });
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication failed: $e'},
    );
  }
}