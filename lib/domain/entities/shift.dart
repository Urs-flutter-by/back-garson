import 'package:back_garson/domain/entities/hall.dart';

class Shift {
  final String id;
  final String waiterId;
  final String restaurantId;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final bool isActive;
  final List<Hall>? halls;

  Shift({
    required this.id,
    required this.waiterId,
    required this.restaurantId,
    this.openedAt,
    this.closedAt,
    required this.isActive,
    this.halls,
  });
}
