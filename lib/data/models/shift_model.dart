// lib/data/models/shift_model.dart
//import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/domain/entities/shift.dart';

class ShiftModel extends Shift {
  ShiftModel({
    required super.id,
    required super.waiterId,
    required super.restaurantId,
    super.openedAt,
    super.closedAt,
    required super.isActive,
    //super.halls,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as String? ?? '',
      waiterId: json['waiterId'] as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      openedAt: json['openedAt'] != null ? DateTime.parse(json['openedAt'] as String) : null,
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt'] as String) : null,
      isActive: json['isActive'] as bool? ?? false,
      //halls: (json['halls'] as List<dynamic>?)?.map((e) => HallModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'shiftOpen': isActive,
      'openedAt': openedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      //'halls': halls?.map((h) => h.toJson()).toList() ?? [],
    };
  }
}