import 'package:back_garson/data/models/category_model.dart';
import 'package:back_garson/domain/entities/menu.dart';

/// Модель меню, представляющая данные из слоя данных.
///
/// Расширяет [Menu] из доменного слоя.
class MenuModel extends Menu {
  /// Создает экземпляр [MenuModel].
  MenuModel({required super.categories});

  /// Создает [MenuModel] из JSON-объекта.
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      categories: (json['categories'] as List<dynamic>)
          .map((category) =>
              CategoryModel.fromJson(category as Map<String, dynamic>),)
          .toList(),
    );
  }

  /// Преобразует [MenuModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'categories': categories
          .map((category) => (category as CategoryModel).toJson())
          .toList(),
    };
  }
}
