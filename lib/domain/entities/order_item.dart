import 'package:back_garson/domain/entities/dish.dart';

class OrderItem {
  final String dishId;
  final int quantity;
  final Dish? dish; // Опционально
  final String status;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  OrderItem({
    required this.dishId,
    required this.quantity,
    this.dish,
    required this.status,
    this.createdAt,
    this.confirmedAt,
    this.completedAt,
  });
}