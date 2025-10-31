import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';

/// Абстрактный репозиторий для работы с заказами.
///
/// Определяет контракт для управления заказами.
abstract class OrderRepository {
  /// Создает новый заказ для стола [tableId] и опционально привязывает его к сессии.
  Future<Order> createOrder(String tableId, {String? sessionId});

  /// Получает информацию о заказе по его [orderId].
  ///
  /// Возвращает [Future] с объектом [Order] или `null`, если заказ не найден.
  Future<Order?> getOrder(String orderId);

  /// Выполняет "умную" синхронизацию (сравнение) позиций заказа.
  Future<void> diffAndSyncItems(String orderId, List<OrderItem> items, AuthPayload actor);

  /// Выполняет "чистую" вставку всех позиций заказа без сравнения.
  Future<void> bulkInsertItems(String orderId, List<OrderItem> items);

  /// Обновляет статус заказа.
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String? actorId,
  });

  /// Находит активный (незавершенный) заказ для столика.
  Future<Order?> findActiveOrderByTable(String tableId);

  /// Находит ID активного заказа по ID сессии.
  Future<String?> findActiveOrderIdBySession(String sessionId);

  /// Обновляет sessionId для существующего заказа.
  Future<void> updateSessionId(String orderId, String sessionId);
}