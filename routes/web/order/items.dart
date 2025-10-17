import 'dart:convert';
import 'dart:io';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/utils/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

final _log = Logger('WebOrderItemsRoute');

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));

  try {
    // Шаг 1: Аутентификация гостя по JWT-токену
    final authHeader = context.request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(statusCode: 401, body: {'error': 'Требуется токен авторизации'});
    }
    final token = authHeader.substring(7);

    String tableId;
    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      if (payload['role'] != 'CUSTOMER' || payload['tableId'] == null) {
        throw Exception('Невалидный гостевой токен');
      }
      tableId = payload['tableId'] as String;
    } catch (e) {
      return Response.json(statusCode: 401, body: {'error': 'Невалидный или истекший токен'});
    }

    // Шаг 2: Найти активный заказ для столика или создать новый
    final activeOrderResult = await pool.withConnection((conn) => conn.execute(
          r'''
          SELECT order_id FROM orders 
          WHERE table_id = $1 AND status != 'completed' AND status != 'canceled'
          ORDER BY created_at DESC LIMIT 1
          ''',
          parameters: [tableId],
        ));

    String orderId;
    if (activeOrderResult.isNotEmpty) {
      // PostgreSQL возвращает тип UUID как строку
      orderId = activeOrderResult.first.toColumnMap()['order_id'] as String;
    } else {
      final newOrder = await orderService.createOrder(tableId);
      orderId = newOrder.orderId;
    }

    // Шаг 3: Парсим тело запроса, чтобы получить позиции для добавления
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>?;

    if (itemsJson == null || itemsJson.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Список items обязателен'});
    }

    final items = itemsJson.map((itemJson) {
      final itemData = itemJson as Map<String, dynamic>;
      final dishIdRaw = itemData['dishId'];
      final quantityRaw = itemData['quantity'];
      final comment = itemData['comment'] as String?;
      final courseRaw = itemData['course'];
      final serveAtRaw = itemData['serveAt'] as String?;

      if (dishIdRaw == null) {
        throw Exception('dishId is required for each item');
      }
      
      // Парсим dishId как int
      final dishId = dishIdRaw is int
          ? dishIdRaw
          : int.tryParse(dishIdRaw.toString()) ?? (throw Exception('Invalid dishId'));

      final quantity = quantityRaw is int
          ? quantityRaw
          : int.tryParse(quantityRaw.toString()) ?? 1;

      final course = courseRaw is int
          ? courseRaw
          : int.tryParse(courseRaw?.toString() ?? '1') ?? 1;

      final serveAt = serveAtRaw != null ? DateTime.tryParse(serveAtRaw) : null;

      return OrderItemModel(
        dishId: dishId, // Теперь это int
        quantity: quantity,
        status: 'new',
        comment: comment,
        course: course,
        serveAt: serveAt,
      );
    }).toList();

    // Шаг 4: Добавляем позиции в заказ
    await orderService.addOrderItems(orderId, items);

    return Response.json(body: {'message': 'Позиции успешно добавлены в заказ', 'orderId': orderId});

  } catch (e, st) {
    _log.severe('Ошибка при добавлении позиций в заказ', e, st);
    return Response.json(
      statusCode: 500,
      body: {'error': 'Внутренняя ошибка сервера'},
    );
  }
}