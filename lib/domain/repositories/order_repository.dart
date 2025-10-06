import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';

/// Абстрактный репозиторий для работы с заказами.
///
/// Определяет контракт для управления заказами.
abstract class OrderRepository {
  /// Создает новый заказ для стола [tableId].
  ///
  /// Возвращает [Future] с созданной сущностью [Order].
  Future<Order> createOrder(String tableId);

  /// Получает информацию о заказе по его [orderId].
  ///
  /// Возвращает [Future] с объектом [Order] или `null`, если заказ не найден.
  Future<Order?> getOrder(String orderId);

  /// Добавляет новые позиции в существующий заказ.
  ///
  /// Принимает [orderId] заказа и список [items] позиций заказа.
  Future<void> addOrderItems(String orderId, List<OrderItem> items);
}
