// lib/data/models/hall_model.dart
import 'package:back_garson/data/models/table_model.dart';
import 'package:back_garson/domain/entities/hall.dart';

class HallModel extends Hall {
  @override
  final List<TableModel> tables;

  HallModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required this.tables,
  }) : super(tables: tables);

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'tables': tables.map((t) => t.toJson()).toList(),
    };
  }
}
