import 'package:equatable/equatable.dart';

/// Сущность стола.
///
/// Представляет собой стол с его идентификатором, статусом, вместимостью,
/// номером и идентификатором ресторана.
class Table extends Equatable {
  /// Создает экземпляр [Table].
  const Table({
    required this.id,
    required this.status,
    required this.capacity,
    required this.number,
    required this.restaurantId,
  });

  /// Уникальный идентификатор стола.
  final String id;

  /// Текущий статус стола (например, "свободен", "занят").
  final String status;

  /// Максимальная вместимость стола.
  final int capacity;

  /// Номер стола.
  final int number;

  /// Идентификатор ресторана, к которому относится стол.
  final String restaurantId;

  @override
  List<Object?> get props => [id, status, capacity, number, restaurantId];
}
