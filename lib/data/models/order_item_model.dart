import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/domain/entities/order_item.dart';

/// Модель элемента заказа, представляющая данные из слоя данных.
///
/// Расширяет [OrderItem] из доменного слоя.
class OrderItemModel extends OrderItem {
  /// Создает экземпляр [OrderItemModel].
  OrderItemModel({
    required super.dishId,
    required super.quantity,
    required super.status,
    super.dish,
    super.createdAt,
    super.confirmedAt,
    super.completedAt,
    super.comment,
    super.course = 1,
    super.serveAt,
  });

  /// Создает [OrderItemModel] из JSON-объекта.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      dishId: json['dishId'] as String,
      quantity: json['quantity'] as int,
      dish: json['dish'] != null
          ? DishModel.fromJson(json['dish'] as Map<String, dynamic>)
          : null, // Если dish отсутствует, передаём null
      status: json['status'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      comment: json['comment'] as String?,
      course: json['course'] as int? ?? 1, // По умолчанию 1
      serveAt: json['serveAt'] != null
          ? DateTime.parse(json['serveAt'] as String)
          : null,
    );
  }

  /// Преобразует [OrderItemModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'quantity': quantity,
      if (dish != null) 'dish': (dish! as DishModel).toJson(),
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (comment != null) 'comment': comment,
      'course': course,
      if (serveAt != null) 'serveAt': serveAt!.toIso8601String(),
    };
  }
}
