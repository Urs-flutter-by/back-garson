class Dish {
  /// Сущность блюда.
  ///
  /// Представляет собой блюдо с его идентификатором, названием,
/// описанием, ценой,
  /// весом, списком URL изображений и статусом доступности.
  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.weight,
    required this.imageUrls,
    required this.isAvailable,
  });

  /// Уникальный идентификатор блюда.
  final String id;

  /// Название блюда.
  final String name;

  /// Описание блюда.
  final String description;

  /// Цена блюда.
  final double price;

  /// Вес или объем блюда.
  final String weight;

  /// Список URL изображений блюда.
  final List<String> imageUrls;

  /// Статус доступности блюда (true, если доступно для заказа).
  final bool isAvailable;
}
