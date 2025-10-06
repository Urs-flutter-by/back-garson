import 'package:back_garson/domain/entities/waiter_request.dart';

/// Абстрактный репозиторий для работы с запросами официантов.
///
/// Определяет контракт для управления запросами официантов.
// ignore: one_member_abstracts
abstract class WaiterRequestRepository {
  /// Создает новые запросы официантов для указанного стола.
  ///
  /// Принимает [tableId] стола и список [requests] запросов официантов.
  Future<void> createWaiterRequests(
      String tableId, List<WaiterRequest> requests,);
}
