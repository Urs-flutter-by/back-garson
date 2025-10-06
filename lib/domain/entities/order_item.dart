import 'package:back_garson/domain/entities/dish.dart';

/// Сущность элемента заказа.
///
/// Представляет собой отдельную позицию в заказе с информацией о блюде,
/// количестве, статусе и временных метках.
class OrderItem {
  /// Создает экземпляр [OrderItem].
  OrderItem({
    required this.dishId,
    required this.quantity,
    required this.status,
    this.dish,
    this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.comment,
    this.course = 1, // По умолчанию курс 1
    this.serveAt,
  });

  /// Уникальный идентификатор блюда.
  final String dishId;

  /// Количество блюд в заказе.
  final int quantity;

  /// Свойства блюда (опционально).
  final Dish? dish;

  /// Статус готовности элемента заказа.
  ///
  /// Возможные значения: "new", "available", "in_progress", "out_of_stock".
  final String status;

  /// Дата и время создания элемента заказа.
  final DateTime? createdAt;

  /// Дата и время подтверждения элемента заказа.
  final DateTime? confirmedAt;

  /// Дата и время завершения приготовления/выдачи блюда.
  final DateTime? completedAt;

  /// Комментарии или пожелания к блюду (опционально).
  final String? comment;

  /// Порядок подачи блюда (по умолчанию 1).
  final int course;

  /// Желаемое время подачи блюда.
  final DateTime? serveAt;
}
