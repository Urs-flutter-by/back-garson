// lib/domain/entities/shift.dart
import '../../data/models/hall_model.dart';

class Shift {
  final String id;
  final String waiterId;
  final String restaurantId;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final bool isActive;
  final List<HallModel>? halls;

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
