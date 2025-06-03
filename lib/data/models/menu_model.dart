import 'package:back_garson/data/models/category_model.dart';
import 'package:back_garson/domain/entities/menu.dart';

class MenuModel extends Menu {
  MenuModel({required super.categories});

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      categories: (json['categories'] as List<dynamic>)
          .map((category) => CategoryModel.fromJson(category as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => (category as CategoryModel).toJson()).toList(),
    };
  }
}
