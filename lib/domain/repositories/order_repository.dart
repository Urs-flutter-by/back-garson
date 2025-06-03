import 'package:back_garson/domain/entities/order.dart';
import '../entities/order_item.dart';

abstract class OrderRepository {
  Future<Order> createOrder(String tableId);
  Future<Order?> getOrder(String orderId);
  Future<void> addOrderItems(String orderId, List<OrderItem> items);
}
