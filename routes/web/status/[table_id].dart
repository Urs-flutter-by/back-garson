import 'package:back_garson/application/services/table_service.dart';
import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String tableId) async {
  final pool = context.read<Pool<void>>();
  final service = TableService(TableRepositoryImpl(pool));

  try {
    final table = await service.getTableById(tableId);
    return Response.json(
      body: {
        'id': table.id,
        'status': table.status,
        'capacity': table.capacity,
        'number': table.number,
        'restaurantId': table.restaurantId,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Table not found: $e'},
    );
  }
}
