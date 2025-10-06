import 'package:back_garson/domain/entities/order_item.dart';

/// Сущность заказа.
///
/// Представляет собой заказ с его уникальным идентификатором
/// и списком позиций заказа.
class Order {
  /// Создает экземпляр [Order].
  Order({
    required this.orderId,
    required this.items,
  });

  /// Уникальный идентификатор заказа.
  final String orderId;

  /// Список позиций заказа.
  final List<OrderItem> items;
}
