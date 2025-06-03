class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String weight;
  final List<String> imageUrls;
  final bool isAvailable;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.weight,
    required this.imageUrls,
    required this.isAvailable,
  });
}
