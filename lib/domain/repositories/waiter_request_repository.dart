import 'package:back_garson/domain/entities/waiter_request.dart';

///
abstract class WaiterRequestRepository {
  Future<void> createWaiterRequests(String tableId, List<WaiterRequest> requests);
}
