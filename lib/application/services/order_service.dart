import 'dart:convert';

import 'package:back_garson/application/services/connection_manager.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:logging/logging.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с заказами.
class OrderService {
  /// Создает экземпляр [OrderService].
  ///
  /// Требует репозиторий [OrderRepository], который реализует
  /// интерфейс из `lib/domain/repositories/order_repository.dart`.
  OrderService(this.repository);

  /// Репозиторий для доступа к данным о заказах.
  final OrderRepository repository;

  final _log = Logger('OrderService');

  /// Создает новый заказ для стола [tableId].
  ///
  /// Возвращает [Future] с созданной сущностью [Order].
  Future<Order> createOrder(String tableId) async {
    return repository.createOrder(tableId);
  }

  /// Получает заказ по его [orderId].
  ///
  /// Возвращает [Future] с сущностью [Order] или `null`, если заказ не найден.
  Future<Order?> getOrder(String orderId) async {
    return repository.getOrder(orderId);
  }

  /// Добавляет позиции [items] в заказ [orderId].
  ///
  /// Позиции заказа являются экземплярами [OrderItem]
  /// из `lib/domain/entities/order_item.dart`.
  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    return repository.addOrderItems(orderId, items);
  }

  /// Обновляет статус заказа и отправляет уведомление через WebSocket.
  ///
  /// В реальном приложении этот метод будет также обновлять данные в БД.
  /// [targetUserId] - ID пользователя, которому нужно отправить уведомление.
  Future<void> updateOrderStatus(
    String orderId,
    String newStatus,
    String targetUserId,
  ) async {
    _log.info(
      'Имитация: обновление статуса для заказа $orderId на $newStatus...',
    );
    // Здесь будет логика вызова репозитория для обновления БД.
    // await repository.updateOrderStatus(orderId, newStatus);

    // Создаем сообщение для отправки клиенту.
    final message = jsonEncode({
      'event': 'order_status_changed',
      'data': {
        'orderId': orderId,
        'newStatus': newStatus,
      },
    });

    // Отправляем сообщение через наш менеджер соединений.
    ConnectionManager.instance.sendMessage(targetUserId, message);
  }
}
