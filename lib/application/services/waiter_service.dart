// lib/application/services/waiter_service.dart
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с официантами.
///
/// В частности, обрабатывает логику входа официанта в систему.
class WaiterService {
  /// Создает экземпляр [WaiterService].
  ///
  /// Требует репозиторий [WaiterRepository], который реализует
  /// интерфейс из `lib/domain/repositories/waiter_repository.dart`.
  WaiterService(this.repository);

  /// Репозиторий для доступа к данным об официантах.
  final WaiterRepository repository;

  /// Выполняет вход официанта в систему.
  ///
  /// Принимает [username], [password] и [restaurantId].
  /// Возвращает [Future] с сущностью [Waiter]
  /// из `lib/domain/entities/waiter.dart` в случае успеха.
  Future<Waiter> signIn(
    String username,
    String password,
    String restaurantId,
  ) async {
    return repository.signIn(username, password, restaurantId);
  }
}
