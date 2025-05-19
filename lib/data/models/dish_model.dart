import 'package:back_garson/domain/entities/dish.dart';

///
class DishModel extends Dish {
  ///
  DishModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.weight,
    required super.imageUrls,
    required super.isAvailable,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      weight: json['weight'] as String? ?? '',
      imageUrls: (json['imageUrl'] as List<dynamic>?)?.cast<String>() ?? [],
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'weight': weight,
      'imageUrl': imageUrls,
    };

    // Добавляем isAvailable только если оно false
    if (!isAvailable) {
      json['isAvailable'] = isAvailable;
    }

    return json;
  }
}
