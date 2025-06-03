import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';

class OrderService {
  final OrderRepository repository;

  OrderService(this.repository);

  Future<Order> createOrder(String tableId) async {
    return repository.createOrder(tableId);
  }

  Future<Order?> getOrder(String orderId) async {
    return repository.getOrder(orderId);
  }

  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    return repository.addOrderItems(orderId, items);
  }
}
