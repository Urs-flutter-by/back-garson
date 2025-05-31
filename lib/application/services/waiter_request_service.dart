import 'package:back_garson/domain/entities/waiter_request.dart';
import 'package:back_garson/domain/repositories/waiter_request_repository.dart';

class WaiterRequestService {
  final WaiterRequestRepository repository;

  WaiterRequestService(this.repository);

  Future<void> createWaiterRequests(
      String tableId, List<WaiterRequest> requests) async {
    await repository.createWaiterRequests(tableId, requests);
  }
}
