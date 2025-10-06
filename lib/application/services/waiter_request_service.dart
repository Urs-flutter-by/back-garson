import 'package:back_garson/domain/entities/waiter_request.dart';
import 'package:back_garson/domain/repositories/waiter_request_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с запросами официантов.
///
/// Использует [WaiterRequestRepository] для работы с данными
/// и оперирует сущностями [WaiterRequest].
class WaiterRequestService {
  /// Создает экземпляр [WaiterRequestService].
  ///
  /// Требует репозиторий [WaiterRequestRepository], который реализует
  /// интерфейс из `lib/domain/repositories/waiter_request_repository.dart`.
  WaiterRequestService(this.repository);

  /// Репозиторий для доступа к данным о запросах официантов.
  final WaiterRequestRepository repository;

  /// Создает новые запросы официанта для указанного стола.
  ///
  /// Принимает идентификатор стола [tableId] и список запросов [requests],
  /// которые являются экземплярами [WaiterRequest] из `lib/domain/entities/waiter_request.dart`.
  Future<void> createWaiterRequests(
    String tableId,
    List<WaiterRequest> requests,
  ) async {
    await repository.createWaiterRequests(tableId, requests);
  }
}
