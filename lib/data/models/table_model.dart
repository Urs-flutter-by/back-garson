import 'package:back_garson/domain/entities/table.dart';

// класс TableModel наследуется от Table и добавляет
// методы для сериализации/десериализации (например, fromJson, toJson).
// Этот класс нужен для преобразования данных из базы (или JSON) в
// сущность Table и обратно. Он живёт в слое data, который отвечает
// за взаимодействие с внешними источниками (база данных, API).


class TableModel extends Table {
  TableModel({
    required super.id,
    required super.status,
    required super.capacity,
    required super.number,
    required super.restaurantId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String,
      status: json['status'] as String,
      capacity: json['capacity'] as int,
      number: json['number'] as int,
      restaurantId: json['restaurantId'] as String, // Изменяем ключ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'capacity': capacity,
      'number': number,
      'restaurantId': restaurantId, // Меняем ключ на restaurantName
    };
  }
}
