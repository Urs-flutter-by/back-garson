import 'dart:io';

import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

/// Middleware для проверки статуса подписки аккаунта.
///
/// Проверяет, что аккаунт, к которому принадлежит пользователь,
/// имеет активную и оплаченную подписку.
Middleware subscriptionStatusMiddleware() {
  return (handler) {
    return (context) async { // Делаем обработчик асинхронным
      final payload = context.read<AuthPayload?>();

      // Если нет payload или роль гостевая/суперадмин, то пропускаем проверку.
      if (payload == null ||
          payload.role == 'CUSTOMER' ||
          payload.role == 'SUPER_ADMIN') {
        return handler(context);
      }

      final pool = context.read<Pool<void>>();

      try {
        // 1. Определяем account_id пользователя.
        final userResult = await pool.withConnection(
          (conn) => conn.execute(
            r'SELECT account_id FROM users WHERE id = @id',
            parameters: {'id': payload.userId},
          ),
        );

        if (userResult.isEmpty) {
          return Response.json(
            statusCode: HttpStatus.forbidden,
            body: {'error': 'Не удалось найти родительский аккаунт'},
          );
        }
        final accountId = userResult.first.toColumnMap()['account_id'] as String;

        // 2. Проверяем подписку этого аккаунта.
        final subResult = await pool.withConnection(
          (conn) => conn.execute(
            r'''
            SELECT status, valid_until FROM subscriptions 
            WHERE account_id = @id ORDER BY created_at DESC LIMIT 1
            ''',
            parameters: {'id': accountId},
          ),
        );

        if (subResult.isEmpty) {
          return Response.json(
            statusCode: HttpStatus.paymentRequired, // 402
            body: {'error': 'Подписка для вашего аккаунта не найдена'},
          );
        }

        final subscription = subResult.first.toColumnMap();
        final status = subscription['status'] as String;
        final validUntil = subscription['valid_until'] as DateTime;

        // 3. Проверяем статус и дату.
        if (status != 'active' || validUntil.isBefore(DateTime.now())) {
           return Response.json(
            statusCode: HttpStatus.paymentRequired, // 402
            body: {'error': 'Ваша подписка неактивна'},
          );
        }

        // Если все проверки пройдены, передаем управление дальше.
        return handler(context);

      } catch (e) {
        return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {'error': 'Ошибка при проверке подписки: $e'},
        );
      }
    };
  };
}
