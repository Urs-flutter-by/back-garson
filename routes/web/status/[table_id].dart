import 'package:back_garson/application/services/table_service.dart';
import 'package:dart_frog/dart_frog.dart';


Future<Response> onRequest(RequestContext context, String tableId) async {
  final service = context.read<TableService>();
  try {
    final table = await service.getTableById(tableId);
    return Response.json(body: {
      'id': table.id,
      'status': table.status,
      'capacity': table.capacity,
      'number': table.number,
      'restaurantId': table.restaurantId,
    });
  } catch (e) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Table not found: $e'},
    );
  }
}
