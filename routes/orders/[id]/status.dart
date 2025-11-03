import 'dart:io';

import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String orderId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final orderService = OrderService(OrderRepositoryImpl(pool));
  final payload = context.read<AuthPayload>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final newStatus = body['newStatus'] as String?;

    if (newStatus == null) {
      return Response.json(
          statusCode: 400, body: {'error': 'Поле newStatus обязательно'});
    }

    // Вызываем сервис для выполнения всей логики
    await orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        actorId: payload.userId ?? payload.sessionId!);

    return Response.json(body: {'message': 'Статус заказа успешно обновлен'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Ошибка при обновлении статуса: $e'},
    );
  }
}
