// lib/data/repositories/waiter_repository_impl.dart
import 'package:back_garson/data/models/waiter_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/waiter.dart';
import 'package:back_garson/domain/repositories/waiter_repository.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class WaiterRepositoryImpl implements WaiterRepository {
  final DatabaseSource database;

  WaiterRepositoryImpl(this.database);

  @override
  Future<Waiter> signIn(String username, String password, String restaurantId) async {
    final conn = await database.connection;
    try {
      final result = await conn.execute(
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

      return WaiterModel.fromJson({
        'id': result[0][0] as String,
        'username': result[0][1] as String,
        'restaurantId': result[0][2] as String,
      });
    } finally {
      await conn.close();
    }
  }

  // Временная функция для хэширования пароля (замени на bcrypt в продакшене)
  String _hashPassword(String password) {
    return md5
        .convert(utf8.encode(password))
        .toString(); // Используй bcrypt в реальном проекте
  }
}
