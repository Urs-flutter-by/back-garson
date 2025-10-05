import 'package:back_garson/domain/entities/table.dart';

// класс TableModel наследуется от Table и добавляет
// методы для сериализации/десериализации (например, fromJson, toJson).
// Этот класс нужен для преобразования данных из базы (или JSON) в
// сущность Table и обратно. Он живёт в слое data, который отвечает
// за взаимодействие с внешними источниками (база данных, API).

class TableModel extends Table {
  final String? hallId;
  final bool isOwn;
  final bool hasNewOrder;
  final bool hasGuestRequest;
  final bool hasInProgressOrder;
  final bool hasInProgressRequest;

  TableModel({
    required super.id,
    this.hallId,
    required super.restaurantId,
    required super.number,
    required super.status,
    this.isOwn = false,
    this.hasNewOrder = false,
    this.hasGuestRequest = false,
    this.hasInProgressOrder = false,
    this.hasInProgressRequest = false,
    required super.capacity,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String? ?? json['tableId'] as String,
      hallId: json['hallId'] as String?,
      restaurantId: json['restaurantId'] as String,
      number: json['number'] as int,
      status: json['status'] as String? ?? 'unknown',
      isOwn: json['isOwn'] as bool? ?? false,
      hasNewOrder: json['hasNewOrder'] as bool? ?? false,
      hasGuestRequest: json['hasGuestRequest'] as bool? ?? false,
      hasInProgressOrder: json['hasInProgressOrder'] as bool? ?? false,
      hasInProgressRequest: json['hasInProgressRequest'] as bool? ?? false,
      capacity: json['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hallId': hallId,
      'restaurantId': restaurantId,
      'number': number,
      'status': status,
      'isOwn': isOwn,
      'hasNewOrder': hasNewOrder,
      'hasGuestRequest': hasGuestRequest,
      'hasInProgressOrder': hasInProgressOrder,
      'hasInProgressRequest': hasInProgressRequest,
      'capacity': capacity,
    };
  }

  //   return {
  //     'id': id,
  //     'restaurantId': restaurantId,
  //     'number': number,
  //     'status': status,
  //     'capacity': capacity,
  //   };
  // }
}