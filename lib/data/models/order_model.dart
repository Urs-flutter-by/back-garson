import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/domain/entities/order.dart';

/// Модель заказа, представляющая данные из слоя данных.
///
/// Расширяет [Order] из доменного слоя.
class OrderModel extends Order {
  /// Создает экземпляр [OrderModel].
  const OrderModel({
    required super.orderId,
    required super.items,
    super.waiterId,
    super.chefId,
  });

  /// Создает [OrderModel] из JSON-объекта.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      waiterId: json['waiterId'] as String?,
      chefId: json['chefId'] as String?,
    );
  }

  /// Преобразует [OrderModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
    };
  }
}
