// lib/domain/repositories/shift_repository.dart

import 'package:back_garson/domain/entities/shift.dart';

abstract class ShiftRepository {
  Future<Shift> checkShift(String waiterId);
  Future<Shift> openShift(String waiterId, String restaurantId);
}