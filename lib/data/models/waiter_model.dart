// lib/data/models/waiter_model.dart
import 'package:back_garson/domain/entities/waiter.dart';

/// Модель официанта, представляющая данные из слоя данных.
///
/// Расширяет [Waiter] из доменного слоя.
class WaiterModel extends Waiter {
  /// Создает экземпляр [WaiterModel].
  WaiterModel({
    required super.id,
    required super.username,
    required super.restaurantId,
  });

  /// Создает [WaiterModel] из JSON-объекта.
  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['id'] as String,
      username: json['username'] as String,
      restaurantId: json['restaurantId'] as String,
    );
  }

  /// Преобразует [WaiterModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'restaurantId': restaurantId,
    };
  }
}
