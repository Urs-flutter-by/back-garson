import '../../domain/entities/restaurant_themes.dart';

class RestaurantThemeModel extends RestaurantTheme {
  RestaurantThemeModel({
    required super.id,
    required super.restaurantId,
    super.themeColors = const {},
    super.fonts = const {},
    super.images = const {},
  });

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
