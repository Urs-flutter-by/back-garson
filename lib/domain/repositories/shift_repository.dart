// lib/domain/repositories/shift_repository.dart

import 'package:back_garson/domain/entities/shift.dart';

/// Абстрактный репозиторий для работы со сменами.
///
/// Определяет контракт для управления сменами.
abstract class ShiftRepository {
  /// Проверяет наличие активной смены для официанта.
  ///
  /// Принимает [waiterId] официанта.
  /// Возвращает [Future] с объектом [Shift], представляющим активную смену.
  Future<Shift> checkShift(String waiterId);

  /// Открывает новую смену для официанта.
  ///
  /// Принимает [waiterId] официанта и [restaurantId] ресторана.
  /// Возвращает [Future] с объектом [Shift], представляющим открытую смену.
  Future<Shift> openShift(String waiterId, String restaurantId);
}
