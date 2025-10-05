import 'package:back_garson/application/services/hall_service.dart';
import 'package:back_garson/application/services/shift_service.dart';
import 'package:back_garson/data/models/shift_model.dart';
import 'package:back_garson/data/repositories/hall_repository_impl.dart';
import 'package:back_garson/data/repositories/shift_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final pool = context.read<Pool>();
  final hallService = HallService(HallRepositoryImpl(pool));
  final service = ShiftService(ShiftRepositoryImpl(pool, hallService));

  final body = await context.request.json();
  try {
    final waiterId = body['waiterId'] as String?;
    final restaurantId = body['restaurantId'] as String?;
    if (waiterId == null || restaurantId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields'},
      );
    }
    print('waiterId=$waiterId, restaurantId=$restaurantId');
    final shift = await service.openShift(waiterId, restaurantId);
    final shiftModel = shift as ShiftModel;
    return Response.json(body: shiftModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to open shift: $e'},
    );
  }
}
