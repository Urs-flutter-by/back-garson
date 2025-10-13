import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Сервис для управления активными WebSocket-соединениями.
///
/// Использует паттерн Singleton для глобального доступа.
class ConnectionManager {
  ConnectionManager._();

  /// Статический экземпляр класса (Singleton).
  static final ConnectionManager instance = ConnectionManager._();

  final _log = Logger('ConnectionManager');

  /// Карта для хранения активных соединений.
  /// Ключ - [userId], значение - канал для отправки сообщений.
  final Map<String, WebSocketChannel> _clients = {};

  /// Добавляет нового клиента в пул активных соединений.
  ///
  /// Вызывается при успешной аутентификации WebSocket-соединения.
  void addClient(String userId, WebSocketChannel channel) {
    _clients[userId] = channel;
    _log.info('Клиент подключен: $userId. Всего клиентов: ${_clients.length}');
  }

  /// Удаляет клиента из пула активных соединений.
  ///
  /// Вызывается при разрыве WebSocket-соединения.
  void removeClient(String userId) {
    _clients.remove(userId);
    _log.info('Клиент отключен: $userId. Всего клиентов: ${_clients.length}');
  }

  /// Отправляет сообщение конкретному пользователю, если он онлайн.
  ///
  /// [userId] - ID пользователя, которому нужно отправить сообщение.
  /// [message] - Сообщение для отправки (обычно в формате JSON).
  void sendMessage(String userId, String message) {
    final clientChannel = _clients[userId];
    if (clientChannel != null) {
      try {
        clientChannel.sink.add(message);
        _log.info('Сообщение отправлено пользователю $userId: $message');
      } catch (e) {
        _log.warning('Ошибка при отправке сообщения пользователю $userId: $e');
        // Возможно, соединение уже закрыто, но еще не удалено.
        removeClient(userId);
      }
    } else {
      _log.info('Попытка отправить сообщение оффлайн-пользователю $userId');
    }
  }
}
