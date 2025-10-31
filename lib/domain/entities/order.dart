import 'package:equatable/equatable.dart';

import 'package:back_garson/domain/entities/order_item.dart';

class Order extends Equatable {
  const Order({
    required this.orderId,
    required this.items,
    required this.status,
    this.waiterId,
    this.chefId,
  });

  final String orderId;
  final List<OrderItem> items;
  final String status;
  final String? waiterId;
  final String? chefId;

  @override
  List<Object?> get props => [orderId, items, status, waiterId, chefId];
}