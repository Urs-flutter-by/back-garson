import 'dart:io';
import 'package:back_garson/application/services/waiter_request_service.dart';
import 'package:back_garson/data/models/waiter_request_model.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // Получаем данные из тела запроса

    final payload = await request.json() as Map<String, dynamic>;

    final tableNumber = payload['tableNumber'] as int?;
    final requestsData = payload['requests'] as List<dynamic>?;

    if (tableNumber == null || requestsData == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing tableNumber or requests'},
      );
    }

    final requests = requestsData.map((data) {
      try {
        return WaiterRequestModel.fromJson(data as Map<String, dynamic>);
      } catch (e) {
        throw Exception('Invalid request data: $e');
      }
    }).toList();

    // Получаем сервис

    final service = context.read<WaiterRequestService>();

    // Записываем запросы в базу

    await service.createWaiterRequests(tableNumber, requests);

    return Response.json(
      body: {'message': 'Waiter requests created successfully'},
    );
  } catch (e) {
    // print('❌ Ошибка в обработке запроса: $e\n$stackTrace');
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Failed to create waiter requests: $e'},
    );
  }
}
