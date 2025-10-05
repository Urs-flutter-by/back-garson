import 'package:back_garson/domain/entities/waiter_request.dart';
import 'package:back_garson/domain/repositories/waiter_request_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

class WaiterRequestRepositoryImpl implements WaiterRequestRepository {
  final Pool pool;

  WaiterRequestRepositoryImpl(this.pool);

  @override
  Future<void> createWaiterRequests(
    String tableId,
    List<WaiterRequest> requests,
  ) async {
    try {
      await pool.runTx((ctx) async {
        final tableResult = await ctx.execute(
          r'''
          SELECT id FROM tables WHERE id = $1
          ''',
          parameters: [tableId],
        );

        if (tableResult.isEmpty) {
          throw Exception('Table with id $tableId not found');
        }

        final requestIds = requests.map((r) => r.requestId).toList();

        final existingIdsResult = await ctx.execute(
          r'''
          SELECT request_id FROM waiter_requests WHERE request_id = ANY($1)
          ''',
          parameters: [requestIds],
        );
        final existingIds =
            existingIdsResult.map((row) => row[0]! as String).toSet();

        for (final request in requests) {
          if (existingIds.contains(request.requestId)) {
            continue;
          }

          if (!Uuid.isValidUUID(fromString: request.requestId)) {
            throw Exception(
              'Invalid UUID format for requestId: ${request.requestId}',
            );
          }

          await ctx.execute(
            r'''
            INSERT INTO waiter_requests (request_id, table_id, message, status, created_at)
            VALUES ($1, $2, $3, $4, $5)
            ''',
            parameters: [
              request.requestId,
              tableId,
              request.message,
              request.status,
              request.timestamp.toIso8601String(),
            ],
          );
        }
      });
    } catch (e) {
      print('Error in createWaiterRequests: $e');
      throw Exception('Failed to create waiter requests: $e');
    }
  }
}
