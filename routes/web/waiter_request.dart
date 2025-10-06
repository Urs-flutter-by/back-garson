import 'dart:io';

import 'package:back_garson/application/services/waiter_request_service.dart';
import 'package:back_garson/data/models/waiter_request_model.dart';
import 'package:back_garson/data/repositories/waiter_request_repository_impl.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;

  if (request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final pool = context.read<Pool<void>>();
  final service = WaiterRequestService(WaiterRequestRepositoryImpl(pool));

  try {
    final payload = await request.json() as Map<String, dynamic>;

    final tableNumber = payload['tableNumber'] as String?;

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

    await service.createWaiterRequests(tableNumber, requests);

    return Response.json(
      body: {'message': 'Waiter requests created successfully'},
    );
  } catch (e) {
    // print('❌ Ошибка в обработке запроса: $e');
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Failed to create waiter requests: $e'},
    );
  }
}
