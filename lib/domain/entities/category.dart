import 'package:back_garson/domain/entities/dish.dart';

/// Сущность категории меню.
///
/// Представляет собой категорию блюд с ее идентификатором,
/// названием и списком блюд.
class Category {
  /// Создает экземпляр [Category].
  Category({
    required this.id,
    required this.name,
    required this.dishes,
  });

  /// Уникальный идентификатор категории.
  final String id;

  /// Название категории.
  final String name;

  /// Список блюд, принадлежащих этой категории.
  final List<Dish> dishes;
}
