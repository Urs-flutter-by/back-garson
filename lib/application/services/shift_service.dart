// lib/application/services/shift_service.dart
import 'package:back_garson/domain/entities/shift.dart';
import 'package:back_garson/domain/repositories/shift_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную со сменами.
class ShiftService {
  /// Создает экземпляр [ShiftService].
  ///
  /// Требует репозиторий [ShiftRepository], который реализует
  /// интерфейс из `lib/domain/repositories/shift_repository.dart`.
  ShiftService(this.repository);

  /// Репозиторий для доступа к данным о сменах.
  final ShiftRepository repository;

  /// Проверяет текущий статус смены для официанта [waiterId].
  ///
  /// Возвращает [Future] с сущностью [Shift]
  /// из `lib/domain/entities/shift.dart`.
  Future<Shift> checkShift(String waiterId) async {
    return repository.checkShift(waiterId);
  }

  /// Открывает новую смену для официанта [waiterId] в ресторане [restaurantId].
  ///
  /// Возвращает [Future] с сущностью [Shift], представляющей открытую смену.
  Future<Shift> openShift(String waiterId, String restaurantId) async {
    return repository.openShift(waiterId, restaurantId);
  }
}
