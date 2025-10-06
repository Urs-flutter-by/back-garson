import 'package:back_garson/domain/entities/waiter.dart';

/// Абстрактный репозиторий для работы с официантами.
///
/// Определяет контракт для управления данными официантов.
// ignore: one_member_abstracts
abstract class WaiterRepository {
  /// Выполняет вход официанта в систему.
  ///
  /// Принимает [id], [username] и [restaurantId].
  /// Возвращает [Future] с объектом [Waiter] в случае успешного входа.
  Future<Waiter> signIn(String id, String username, String restaurantId);
}
