import 'package:back_garson/domain/entities/restaurant_themes.dart';

/// Модель темы ресторана, представляющая данные из слоя данных.
///
/// Расширяет [RestaurantTheme] из доменного слоя.
class RestaurantThemeModel extends RestaurantTheme {
  /// Создает экземпляр [RestaurantThemeModel].
  RestaurantThemeModel({
    required super.id,
    required super.restaurantId,
    super.themeColors = const {},
    super.fonts = const {},
    super.images = const {},
  });

  /// Создает [RestaurantThemeModel] из JSON-объекта.
  factory RestaurantThemeModel.fromJson(Map<String, dynamic> json) {
    return RestaurantThemeModel(
      id: json['id'].toString(),
      restaurantId: json['restaurant_id'].toString(),
      themeColors: (json['theme_colors'] as Map<dynamic, dynamic>?)
              ?.cast<String, String>() ??
          {},
      fonts:
          (json['fonts'] as Map<dynamic, dynamic>?)?.cast<String, String>() ??
              {},
      images:
          (json['images'] as Map<dynamic, dynamic>?)?.cast<String, String>() ??
              {},
    );
  }

  /// Преобразует [RestaurantThemeModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'theme_colors': themeColors,
      'fonts': fonts,
      'images': images,
    };
  }
}
