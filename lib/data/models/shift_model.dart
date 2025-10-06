// lib/data/models/shift_model.dart
//import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/domain/entities/shift.dart';

/// Модель смены, представляющая данные из слоя данных.
///
/// Расширяет [Shift] из доменного слоя.
class ShiftModel extends Shift {
  /// Создает экземпляр [ShiftModel].
  ShiftModel({
    required super.id,
    required super.waiterId,
    required super.restaurantId,
    required super.isActive,
    required List<HallModel> halls,
    super.openedAt,
    super.closedAt,
  }) : super(halls: halls);

  /// Создает [ShiftModel] из JSON-объекта.
  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as String? ?? '',
      waiterId: json['waiterId'] as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'] as String)
          : null,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      halls: (json['halls'] as List<dynamic>?)
              ?.map((e) => HallModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Преобразует [ShiftModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'shiftOpen': isActive,
      'openedAt': openedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'halls': halls?.map((h) => (h as HallModel).toJson()).toList() ?? [],
    };
  }
}
