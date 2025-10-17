import 'dart:convert';

import 'package:back_garson/application/services/connection_manager.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
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

  /// Обновляет статус заказа и отправляет уведомления через WebSocket.
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required AuthPayload actor,
  }) async {
    // В реальном приложении здесь была бы бизнес-логика, проверяющая,
    // может ли пользователь с ролью actor.role установить статус newStatus.
    _log.info(
      'Пользователь ${actor.userId ?? actor.sessionId} меняет статус заказа $orderId на $newStatus',
    );

    // Шаг 1: Обновляем данные в базе данных.
    // Мы передаем ID актора, чтобы записать его в историю.
    await repository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      actorId: actor.userId ?? actor.sessionId!, // Используем ID сессии, если нет ID юзера
    );

    // Шаг 2: Отправляем WebSocket уведомления.
    // Получаем детали заказа, чтобы знать, кого уведомлять.
    final order = await repository.getOrder(orderId);
    if (order == null) return;

    // Формируем сообщение.
    final message = jsonEncode({
      'event': 'order_status_changed',
      'data': {
        'orderId': orderId,
        'newStatus': newStatus,
      },
    });

    // Определяем, кому отправить уведомление.
    final targets = <String>{};
    if (order.waiterId != null) targets.add(order.waiterId!);
    if (order.chefId != null) targets.add(order.chefId!);
    
    // TODO: Добавить логику для уведомления клиента.
    // Для этого нужно будет хранить связь tableId/sessionId с заказом.

    // Рассылаем уведомления всем причастным.
    for (final targetId in targets) {
      // Не отправляем уведомление тому, кто сам инициировал изменение.
      if (targetId != actor.userId) {
        ConnectionManager.instance.sendMessage(targetId, message);
      }
    }
  }
}
