/// Сущность темы ресторана.
///
/// Представляет собой набор настроек темы для ресторана,
/// включая цвета, шрифты и изображения.
class RestaurantTheme {
  /// Создает экземпляр [RestaurantTheme].
  RestaurantTheme({
    required this.id,
    required this.restaurantId,
    this.themeColors = const {},
    this.fonts = const {},
    this.images = const {},
  });

  /// Уникальный идентификатор темы.
  final String id;

  /// Идентификатор ресторана, к которому относится тема.
  final String restaurantId;

  /// Карта цветов темы (например, {'primary': '#FF0000'}).
  final Map<String, String> themeColors;

  /// Карта шрифтов темы (например, {'body': 'Roboto'}).
  final Map<String, String> fonts;

  /// Карта URL изображений темы (например, {'logo': 'http://example.com/logo.png'}).
  final Map<String, String> images;
}
