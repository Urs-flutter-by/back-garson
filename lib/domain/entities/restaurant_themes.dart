class RestaurantTheme {
  final String id;
  final String restaurantId;
  final Map<String, String> themeColors;
  final Map<String, String> fonts;
  final Map<String, String> images;

  RestaurantTheme({
    required this.id,
    required this.restaurantId,
    this.themeColors = const {},
    this.fonts = const {},
    this.images = const {},
  });
}
