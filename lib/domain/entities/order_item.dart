import 'package:back_garson/domain/entities/dish.dart';

/// Модель заказа блюда
class OrderItem {
  /// id блюда
  final String dishId;

  /// количество блюд в заказе
  final int quantity;

  /// свойства блюда
  final Dish? dish; // Опционально

  /// статус готовности: Возможные значения: "new", "available",
  /// "in_progress", "out_of_stock"
  final String status;

  /// дата-время создания заказа
  final DateTime? createdAt;

  /// дата-время принятия заказа
  final DateTime? confirmedAt;

  /// дата выдачи блюда
  final DateTime? completedAt;

  /// коментарии, пожелания к блюду- опционально
  final String? comment;

  ///порядок подачи блюда: 1 - первым и т/д
  final int course; // по умолчанию 1

  /// время для выдачи блюда
  final DateTime? serveAt;


  OrderItem({
    required this.dishId,
    required this.quantity,
    required this.status, this.dish,
    this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.comment,
    this.course = 1, // По умолчанию курс 1
    this.serveAt,
  });
}
