import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// Реализация репозитория для работы с заказами.
///
/// Реализует интерфейс [OrderRepository] из `lib/domain/repositories/order_repository.dart`.
class OrderRepositoryImpl implements OrderRepository {
  /// Создает экземпляр [OrderRepositoryImpl].
  ///
  /// Требует пул соединений [pool].
  OrderRepositoryImpl(this.pool);

  /// Пул соединений с базой данных.
  final Pool<void> pool;

  static final _log = Logger('OrderRepositoryImpl');

  @override

  /// Создает новый заказ для стола [tableId].
  ///
  /// В случае ошибки или если стол не найден, выбрасывает исключение.
  /// Возвращает [Future] с созданной сущностью [Order].
  Future<Order> createOrder(String tableId) async {
    try {
      return await pool.runTx((ctx) async {
        // Проверяем, существует ли столик
        final tableResult = await ctx.execute(
          r'''
          SELECT t.id, t.restaurant_id
          FROM tables t
          WHERE t.id = $1
          ''',
          parameters: [tableId], // UUID как строка
        );

        if (tableResult.isEmpty) {
          throw Exception('Table not found');
        }

        final restaurantId = tableResult[0][1].toString();
        final orderId = const Uuid().v4();

        final orderResult = await ctx.execute(
          r'''
          INSERT INTO orders (order_id, table_id, restaurant_id, status)
          VALUES ($1, $2, $3, 'new')
          RETURNING order_id
          ''',
          parameters: [orderId, tableId, restaurantId],
        );

        if (orderResult.isEmpty) {
          throw Exception('Failed to create order');
        }

        return OrderModel(orderId: orderId, items: []);
      });
    } catch (e, st) {
      _log.severe('Error in createOrder', e, st);
      throw Exception('Failed to create order: $e');
    }
  }

  @override

  /// Получает информацию о заказе по его [orderId].
  ///
  /// Возвращает [Future] с объектом [Order] или `null`, если заказ не найден.
  /// В случае ошибки выбрасывает исключение.
  Future<Order?> getOrder(String orderId) async {
    try {
      return await pool.withConnection((connection) async {
        final orderResult = await connection.execute(
          r'''
          SELECT order_id, table_id, restaurant_id
          FROM orders
          WHERE order_id = $1
          ''',
          parameters: [orderId],
        );

        if (orderResult.isEmpty) {
          return null;
        }

        final itemsResult = await connection.execute(
          r'''
          SELECT 
            dish_id, 
            quantity, 
            status, 
            created_at, 
            confirmed_at, 
            completed_at, 
            comment, 
            course, 
            serve_at
          FROM order_items
          WHERE order_id = $1
          ''',
          parameters: [orderId],
        );

        final items = <OrderItem>[];
        for (final row in itemsResult) {
          final dishId = row[0]! as int;
          final quantity = row[1]! as int;
          final status = row[2]! as String;
          final createdAt = row[3] as DateTime?;
          final confirmedAt = row[4] as DateTime?;
          final completedAt = row[5] as DateTime?;
          final comment = row[6] as String?;
          final course = row[7]! as int;
          final serveAt = row[8] as DateTime?;

          final dishResult = await connection.execute(
            r'''
            SELECT id, name, price, weight, is_available
            FROM dishes
            WHERE id = $1
            ''',
            parameters: [dishId],
          );

          if (dishResult.isEmpty) {
            throw Exception('Dish with id $dishId not found');
          }

          final dishRow = dishResult.first;
          final priceRaw = dishRow[2].toString();
          final price = double.tryParse(priceRaw);
          if (price == null) {
            throw Exception('Invalid price format for dish $dishId: $priceRaw');
          }

          final dish = DishModel(
            id: dishRow[0].toString(),
            name: dishRow[1]! as String,
            description: '',
            price: price,
            weight: dishRow[3]! as String,
            imageUrls: [],
            isAvailable: dishRow[4]! as bool,
          );

          items.add(
            OrderItemModel(
              dishId: dishId,
              quantity: quantity,
              status: status,
              dish: dish,
              createdAt: createdAt,
              confirmedAt: confirmedAt,
              completedAt: completedAt,
              comment: comment,
              course: course,
              serveAt: serveAt,
            ),
          );
        }

        final orderRow = orderResult.first;
        return OrderModel(
          orderId: orderRow[0]! as String,
          items: items,
        );
      });
    } catch (e, st) {
      _log.severe('Error in getOrder', e, st);
      throw Exception('Failed to get order: $e');
    }
  }

  @override

  /// Добавляет новые позиции в существующий заказ.
  ///
  /// Принимает [orderId] заказа и список [items] позиций заказа.
  /// В случае ошибки выбрасывает исключение.
  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    try {
      await pool.runTx((ctx) async {
        // Проверяем существование заказа
        final orderResult = await ctx.execute(
          r'''SELECT 1 FROM orders WHERE order_id = $1''',
          parameters: [orderId],
        );
        if (orderResult.isEmpty) {
          throw Exception('Order with id $orderId not found');
        }

        // Получаем все существующие элементы заказа
        final existingItemsResult = await ctx.execute(
          r'''SELECT dish_id, quantity, status FROM order_items WHERE order_id = $1''',
          parameters: [orderId],
        );

        // Теперь ключ - int, как и должно быть
        final existingItems = <int, Map<String, dynamic>>{};
        for (final row in existingItemsResult) {
          final map = row.toColumnMap();
          existingItems[map['dish_id'] as int] = {
            'quantity': map['quantity'] as int,
            'status': map['status'] as String,
          };
        }

        for (final item in items) {
          // item.dishId теперь int, никаких преобразований не нужно
          final dishId = item.dishId;

          // Проверяем существование блюда
          final dishExists = await ctx.execute(
            r'SELECT 1 FROM dishes WHERE id = $1',
            parameters: [dishId],
          );
          if (dishExists.isEmpty) {
            throw Exception('Dish with id $dishId not found');
          }

          // Проверяем, есть ли уже такая позиция в заказе
          if (existingItems.containsKey(dishId)) {
            final existing = existingItems[dishId]!;
            // Обновляем только если статус 'new' (например, клиент передумал и изменил кол-во)
            if (existing['status'] == 'new') {
              await ctx.execute(
                r'''
                UPDATE order_items SET quantity = $1, comment = $2, course = $3, serve_at = $4
                WHERE order_id = $5 AND dish_id = $6 AND status = 'new'
                ''',
                parameters: [item.quantity, item.comment, item.course, item.serveAt, orderId, dishId],
              );
            }
            // Если статус другой (уже готовится), ничего не делаем
          } else {
            // Если позиции нет, добавляем новую
            await ctx.execute(
              r'''
              INSERT INTO order_items (order_id, dish_id, quantity, status, comment, course, serve_at)
              VALUES ($1, $2, $3, 'new', $4, $5, $6)
              ''',
              parameters: [orderId, dishId, item.quantity, item.comment, item.course, item.serveAt],
            );
          }
        }
      });
    } catch (e, st) {
      _log.severe('Error in addOrderItems', e, st);
      throw Exception('Failed to add order items: $e');
    }
  }
}
