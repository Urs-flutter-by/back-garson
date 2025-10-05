import 'dart:convert';

import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';

class WaiterRepositoryImpl implements WaiterRepository {
  final Pool<void> pool;

  WaiterRepositoryImpl(this.pool);

  @override
  Future<Waiter> signIn(
      String username, String password, String restaurantId) async {
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
        'id': row[0] as String,
        'username': row[1] as String,
        'restaurantId': row[2] as String,
      });
    } catch (e) {
      print('Error in signIn: $e');
      rethrow;
    }
  }

  // Временная функция для хэширования пароля (замени на bcrypt в продакшене)
  String _hashPassword(String password) {
    return md5
        .convert(utf8.encode(password))
        .toString(); // Используй bcrypt в реальном проекте
  }
}
