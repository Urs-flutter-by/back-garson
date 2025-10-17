import 'package:equatable/equatable.dart';

import 'package:back_garson/domain/entities/order_item.dart';

/// Сущность заказа.
///
/// Представляет собой заказ с его уникальным идентификатором
/// и списком позиций заказа.
class Order extends Equatable {
  /// Создает экземпляр [Order].
  const Order({
    required this.orderId,
    required this.items,
    this.waiterId,
    this.chefId,
  });

  /// Уникальный идентификатор заказа.
  final String orderId;

  /// Список позиций в заказе.
  final List<OrderItem> items;

  /// ID официанта, привязанного к заказу.
  final String? waiterId;

  /// ID повара, привязанного к заказу.
  final String? chefId;

  @override
  List<Object?> get props => [orderId, items, waiterId, chefId];
}
