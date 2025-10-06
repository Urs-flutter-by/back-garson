import 'package:back_garson/domain/entities/hall.dart';

/// Сущность смены.
///
/// Представляет собой смену официанта с ее идентификатором,
/// идентификатором официанта,
/// идентификатором ресторана, статусом активности, временем открытия
/// и закрытия,
/// а также списком залов, обслуживаемых в эту смену.
class Shift {
  /// Создает экземпляр [Shift].
  Shift({
    required this.id,
    required this.waiterId,
    required this.restaurantId,
    required this.isActive,
    this.openedAt,
    this.closedAt,
    this.halls,
  });

  /// Уникальный идентификатор смены.
  final String id;

  /// Идентификатор официанта, к которому относится смена.
  final String waiterId;

  /// Идентификатор ресторана, в котором проходит смена.
  final String restaurantId;

  /// Время открытия смены.
  final DateTime? openedAt;

  /// Время закрытия смены.
  final DateTime? closedAt;

  /// Статус активности смены (true, если смена активна).
  final bool isActive;

  /// Список залов, обслуживаемых в эту смену.
  final List<Hall>? halls;
}
