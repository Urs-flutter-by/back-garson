import 'package:back_garson/domain/entities/dish.dart';

class Category {
  final String id;
  final String name;
  final List<Dish> dishes;

  Category({
    required this.id,
    required this.name,
    required this.dishes,
  });
}