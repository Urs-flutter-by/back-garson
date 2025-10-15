import 'package:back_garson/application/services/connection_manager.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:logging/logging.dart';

final _log = Logger('WebSocketRoute');

/// Обрабатывает запросы на установку WebSocket-соединения.
Future<Response> onRequest(RequestContext context) async {
  // Создаем основной обработчик для логики WebSocket.
  final handler = webSocketHandler((channel, protocol) {
    // Эта функция выполнится только ПОСЛЕ успешной аутентификации.

    final payload = context.read<AuthPayload>();
    final userId = payload.userId;

    // Этот эндпоинт только для сотрудников, у которых есть userId.
    if (userId == null) {
      channel.sink.close(1008, 'Invalid user type');
      return;
    }

    // Регистрируем нового клиента в менеджере соединений.
    ConnectionManager.instance.addClient(userId, channel);

    // Слушаем канал, чтобы узнать, когда клиент отключится.
    channel.stream.listen(
      (message) {
        // Пока просто логируем входящие сообщения. В будущем здесь
        // можно будет обрабатывать команды от клиента (например, пинг).
        _log.info('Получено сообщение от $userId: $message');
      },
      onDone: () {
        // Клиент отключился, удаляем его из менеджера.
        ConnectionManager.instance.removeClient(userId);
      },
      onError: (Object error) {
        // Произошла ошибка, удаляем клиента.
        _log.warning('Ошибка в канале у $userId: $error');
        ConnectionManager.instance.removeClient(userId);
      },
    );
  });

  // "Оборачиваем" наш WebSocket-обработчик в middleware аутентификации.
  // Это гарантирует, что анонимный пользователь не сможет установить соединение.
  final protectedHandler = handler.use(authenticationMiddleware());

  // Запускаем всю цепочку.
  return protectedHandler(context);
}
