// lib/domain/repositories/shift_repository.dart
import 'package:back_garson/data/models/shift_model.dart';

import '../entities/shift.dart';

abstract class ShiftRepository {
  Future<Shift> checkShift(String waiterId);
  Future<Shift> openShift(String waiterId, String restaurantId);
}