import 'dart:convert';

import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';

/// Реализация репозитория для работы с официантами.
///
/// Реализует интерфейс [WaiterRepository] из `lib/domain/repositories/waiter_repository.dart`.
class WaiterRepositoryImpl implements WaiterRepository {
  /// Создает экземпляр [WaiterRepositoryImpl].
  ///
  /// Требует пул соединений [pool].
  WaiterRepositoryImpl(this.pool);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  @override

  /// Выполняет вход официанта в систему.
  ///
  /// Принимает [username], [password] и [restaurantId].
  /// Возвращает [Future] с объектом [Waiter] в случае успешного входа.
  /// В случае неверных учетных данных или ошибки выбрасывает исключение.
  Future<Waiter> signIn(
    String username,
    String password,
    String restaurantId,
  ) async {
    try {
      final result = await pool.execute(
        r'''
        SELECT id, username, restaurant_id
        FROM waiters
        WHERE username = $1 AND password_hash = $2 AND restaurant_id = $3
        ''',
        parameters: [
          username,
          _hashPassword(password),
          restaurantId,
        ],
      );

      if (result.isEmpty) {
        throw Exception('Invalid credentials or restaurant ID');
      }

      final row = result.first;
      return WaiterModel.fromJson({
        'id': row[0]! as String,
        'username': row[1]! as String,
        'restaurantId': row[2]! as String,
      });
    } catch (e) {
      // print('Error in signIn: $e');
      rethrow;
    }
  }

  /// Временная функция для хэширования пароля.
  ///
  /// **ВНИМАНИЕ:** В продакшене используйте более надежные методы
  /// хэширования (например, bcrypt).
  String _hashPassword(String password) {
    return md5
        .convert(utf8.encode(password))
        .toString();
    // Используй bcrypt в реальном проекте
  }
}
