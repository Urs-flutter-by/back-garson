// lib/data/models/hall_model.dart
import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/domain/entities/hall.dart';

/// Модель зала ресторана, представляющая данные из слоя данных.
///
/// Расширяет [Hall] из доменного слоя.
class HallModel extends Hall {
  /// Создает экземпляр [HallModel].
  HallModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required List<TableModel> tables,
  }) : super(tables: tables);

  /// Создает [HallModel] из JSON-объекта.
  factory HallModel.fromJson(Map<String, dynamic> json) {
    return HallModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      tables: (json['tables'] as List<dynamic>)
          .map((e) => TableModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Преобразует [HallModel] в JSON-объект.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'tables': (tables as List<TableModel>).map((t) => t.toJson()).toList(),
    };
  }
}
