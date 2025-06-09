// lib/data/models/waiter_model.dart
import 'package:back_garson/domain/entities/waiter.dart';

class WaiterModel extends Waiter {
  WaiterModel({
    required super.id,
    required super.username,
    required super.restaurantId,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['id'] as String,
      username: json['username'] as String,
      restaurantId: json['restaurantId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'restaurantId': restaurantId,
    };
  }
}
