import 'package:back_garson/domain/entities/restaurant.dart';

/// Модель ресторана, представляющая данные из слоя данных.
///
/// Расширяет [Restaurant] из доменного слоя.
class RestaurantModel extends Restaurant {
  /// Создает экземпляр [RestaurantModel].
  RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.selfOrderDiscount,
  });

  /// Создает [RestaurantModel] из JSON-объекта.
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      selfOrderDiscount: json['self_order_discount'] as int? ?? 0,
    );
  }

  /// Преобразует [RestaurantModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'self_order_discount': selfOrderDiscount,
    };
  }
}
