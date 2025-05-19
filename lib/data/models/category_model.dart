import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.dishes,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String,
      dishes: (json['dishes'] as List<dynamic>)
          .map((dish) => DishModel.fromJson(dish as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dishes': dishes.map((dish) => (dish as DishModel).toJson()).toList(),
    };
  }
}