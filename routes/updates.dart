import 'package:back_garson/application/services/connection_manager.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:logging/logging.dart';

final _log = Logger('WebSocketRoute');

/// Обрабатывает запросы на установку WebSocket-соединения.
Future<Response> onRequest(RequestContext context) async {
  // Создаем финальный обработчик, который будет вызван после всех middleware.
  final handler = (RequestContext context) {
    // Этот контекст уже содержит AuthPayload, если токен валидный.
    return webSocketHandler((channel, protocol) {
      final payload = context.read<AuthPayload>();

      // Определяем уникальный ключ для этой сессии.
      // Для сотрудника это будет userId, для гостя - sessionId.
      final connectionKey = payload.userId ?? payload.sessionId;

      // Если в токене нет ни userId, ни sessionId, то это невалидный токен.
      if (connectionKey == null) {
        channel.sink.close(4001, 'Invalid token payload');
        return;
      }

      // Регистрируем нового клиента в менеджере соединений.
      ConnectionManager.instance.addClient(connectionKey, channel);

      // Слушаем канал, чтобы узнать, когда клиент отключится.
      channel.stream.listen(
        (message) {
          _log.info('Получено сообщение от $connectionKey: $message');
        },
        onDone: () {
          // Клиент отключился, удаляем его из менеджера.
          ConnectionManager.instance.removeClient(connectionKey);
        },
        onError: (Object error) {
          // Произошла ошибка, удаляем клиента.
          _log.warning('Ошибка в канале у $connectionKey: $error');
          ConnectionManager.instance.removeClient(connectionKey);
        },
      );
    })(context);
  };

  // Создаем и применяем цепочку middleware к нашему финальному обработчику.
  return await const Pipeline()
      .addMiddleware(authenticationMiddleware())
      .addHandler(handler)(context);
}