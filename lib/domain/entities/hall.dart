import 'package:back_garson/domain/entities/table.dart';

/// Сущность зала ресторана.
///
/// Представляет собой зал с его идентификатором, идентификатором ресторана,
/// названием и списком столов.
class Hall {
  /// Создает экземпляр [Hall].
  Hall({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.tables,
  });

  /// Уникальный идентификатор зала.
  final String id;

  /// Идентификатор ресторана, к которому относится зал.
  final String restaurantId;

  /// Название зала.
  final String name;

  /// Список столов, находящихся в зале.
  final List<Table> tables;
}
