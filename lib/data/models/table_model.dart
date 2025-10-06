import 'package:back_garson/domain/entities/table.dart';

/// Модель стола, представляющая данные из слоя данных.
///
/// Расширяет [Table] из доменного слоя.
/// Этот класс нужен для преобразования данных из базы (или JSON) в
/// сущность Table и обратно. Он живёт в слое data, который отвечает
/// за взаимодействие с внешними источниками (база данных, API).
class TableModel extends Table {
  /// Создает экземпляр [TableModel].
  const TableModel({
    required super.id,
    required super.restaurantId,
    required super.number,
    required super.status,
    required super.capacity,
    this.hallId,
    this.isOwn = false,
    this.hasNewOrder = false,
    this.hasGuestRequest = false,
    this.hasInProgressOrder = false,
    this.hasInProgressRequest = false,
  });

  /// Создает [TableModel] из JSON-объекта.
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

  /// Идентификатор зала, к которому относится стол.
  final String? hallId;

  /// Флаг, указывающий, является ли стол "своим".
  final bool isOwn;

  /// Флаг, указывающий, есть ли у стола новый заказ.
  final bool hasNewOrder;

  /// Флаг, указывающий, есть ли у стола запрос от гостя.
  final bool hasGuestRequest;

  /// Флаг, указывающий, есть ли у стола заказ в процессе выполнения.
  final bool hasInProgressOrder;

  /// Флаг, указывающий, есть ли у стола запрос в процессе выполнения.
  final bool hasInProgressRequest;

  /// Преобразует [TableModel] в JSON-объект.
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
}
