// lib/application/services/shift_service.dart
import 'package:back_garson/domain/entities/shift.dart';
import 'package:back_garson/domain/repositories/shift_repository.dart';

class ShiftService {
  final ShiftRepository repository;

  ShiftService(this.repository);

  Future<Shift> checkShift(String waiterId) async {
    return repository.checkShift(waiterId);
  }

  Future<Shift> openShift(String waiterId, String restaurantId) async {
    return repository.openShift(waiterId, restaurantId);
  }
}