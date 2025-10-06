/// Сущность ресторана.
///
/// Представляет собой ресторан с его идентификатором, названием, описанием
/// и скидкой на самообслуживание.
class Restaurant {
  /// Создает экземпляр [Restaurant].
  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.selfOrderDiscount,
  });

  /// Уникальный идентификатор ресторана.
  final String id;

  /// Название ресторана.
  final String name;

  /// Описание ресторана.
  final String description;

  /// Процент скидки на самообслуживание.
  final int selfOrderDiscount;
}
