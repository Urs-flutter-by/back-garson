import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.orderId,
    required super.items,
    required super.status,
    super.waiterId,
    super.chefId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      waiterId: json['waiter_id'] as String?,
      chefId: json['chef_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'waiter_id': waiterId,
      'chef_id': chefId,
    };
  }
}
