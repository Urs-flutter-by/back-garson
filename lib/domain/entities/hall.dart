import 'package:back_garson/data/models/table_model.dart';

class Hall {
  final String id;
  final String restaurantId;
  final String name;
  final List<TableModel> tables;

  Hall({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.tables,
  });
}