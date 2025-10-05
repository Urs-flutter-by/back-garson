import 'package:back_garson/domain/entities/table.dart';

class Hall {
  final String id;
  final String restaurantId;
  final String name;
  final List<Table> tables;

  Hall({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.tables,
  });
}