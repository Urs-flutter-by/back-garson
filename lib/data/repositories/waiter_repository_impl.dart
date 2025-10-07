import 'dart:convert';

import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:logging/logging.dart';
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

  static final _log = Logger('WaiterRepositoryImpl');

  @override

  /// Выполняет вход официанта в систему с безопасной проверкой пароля.
  ///
  /// Реализует "ленивую миграцию" с MD5 на bcrypt.
  /// 1. Получает пользователя по имени и ID ресторана.
  /// 2. Проверяет формат хэша (MD5 или bcrypt).
  /// 3. Сравнивает пароль, используя соответствующий алгоритм.
  /// 4. Если пароль верный и хэш MD5, он обновляется на bcrypt.
  Future<Waiter> signIn(
    String username,
    String password,
    String restaurantId,
  ) async {
    try {
      // 1. Получаем пользователя и его хэш из БД
      final result = await pool.execute(
        r'''
        SELECT id, username, password_hash, restaurant_id
        FROM waiters
        WHERE username = $1 AND restaurant_id = $2
        ''',
        parameters: [username, restaurantId],
      );

      if (result.isEmpty) {
        throw Exception('Invalid credentials or restaurant ID');
      }

      final row = result.first;
      final storedHash = row[2]! as String;
      final waiterId = row[0]! as String;

      // 2. Определяем, bcrypt это или md5
      final isBcrypt = storedHash.startsWith(r'$2');
      bool passwordCorrect;

      if (isBcrypt) {
        // 3.А. Проверяем пароль с помощью bcrypt
        passwordCorrect = DBCrypt().checkpw(password, storedHash);
      } else {
        // 3.Б. Проверяем пароль с помощью md5
        final md5Hash = md5.convert(utf8.encode(password)).toString();
        passwordCorrect = (md5Hash == storedHash);

        // 4. Если пароль верный, обновляем хэш до bcrypt
        if (passwordCorrect) {
          final newBcryptHash = DBCrypt().hashpw(password, DBCrypt().gensalt());
          await _updatePasswordHash(waiterId, newBcryptHash);
        }
      }

      if (!passwordCorrect) {
        throw Exception('Invalid credentials');
      }

      return WaiterModel.fromJson({
        'id': waiterId,
        'username': row[1]! as String,
        'restaurantId': row[3]! as String,
      });
    } catch (e, st) {
      _log.warning('Error in signIn', e, st);
      rethrow;
    }
  }

  /// Обновляет хэш пароля для указанного пользователя.
  Future<void> _updatePasswordHash(String waiterId, String newHash) async {
    await pool.execute(
      r'''
      UPDATE waiters
      SET password_hash = $1
      WHERE id = $2
      ''',
      parameters: [newHash, waiterId],
    );
  }
}
