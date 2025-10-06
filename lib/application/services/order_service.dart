import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с заказами.
class OrderService {
  /// Создает экземпляр [OrderService].
  ///
  /// Требует репозиторий [OrderRepository], который реализует
  /// интерфейс из `lib/domain/repositories/order_repository.dart`.
  OrderService(this.repository);

  /// Репозиторий для доступа к данным о заказах.
  final OrderRepository repository;

  /// Создает новый заказ для стола [tableId].
  ///
  /// Возвращает [Future] с созданной сущностью [Order].
  Future<Order> createOrder(String tableId) async {
    return repository.createOrder(tableId);
  }

  /// Получает заказ по его [orderId].
  ///
  /// Возвращает [Future] с сущностью [Order] или `null`, если заказ не найден.
  Future<Order?> getOrder(String orderId) async {
    return repository.getOrder(orderId);
  }

  /// Добавляет позиции [items] в заказ [orderId].
  ///
  /// Позиции заказа являются экземплярами [OrderItem]
  /// из `lib/domain/entities/order_item.dart`.
  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    return repository.addOrderItems(orderId, items);
  }
}
