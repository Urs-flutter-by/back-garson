import 'package:back_garson/domain/entities/order_item.dart';

class Order {
  final String orderId;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.items,
  });
}
