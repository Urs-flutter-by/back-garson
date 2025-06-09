// routes/app/shift/check.dart
import 'package:back_garson/application/services/shift_service.dart';
import 'package:back_garson/data/models/shift_model.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final service = context.read<ShiftService>();
  final body = await context.request.json();

  try {
    final waiterId = body['waiterId'] as String?;
    if (waiterId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing waiterId'},
      );
    }

    final shift = await service.checkShift(waiterId);
    final shiftModel = shift as ShiftModel;
    return Response.json(body: shiftModel.toJson());
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to check shift: $e'},
    );
  }
}