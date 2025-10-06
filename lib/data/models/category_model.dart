import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/domain/entities/category.dart';

/// Модель категории меню, представляющая данные из слоя данных.
///
/// Расширяет [Category] из доменного слоя.
class CategoryModel extends Category {
  /// Создает экземпляр [CategoryModel].
  CategoryModel({
    required super.id,
    required super.name,
    required super.dishes,
  });

  /// Создает [CategoryModel] из JSON-объекта.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String,
      dishes: (json['dishes'] as List<dynamic>)
          .map((dish) => DishModel.fromJson(dish as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Преобразует [CategoryModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dishes': dishes.map((dish) => (dish as DishModel).toJson()).toList(),
    };
  }
}
