import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/data/models/order_item_model.dart';

class OrderModel extends Order {
  OrderModel({
    required super.orderId,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
    };
  }
}