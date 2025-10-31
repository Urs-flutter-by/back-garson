import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/domain/entities/auth_payload.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this.pool);

  final Pool<void> pool;
  static final _log = Logger('OrderRepositoryImpl');

  @override
  Future<Order> createOrder(String tableId, {String? sessionId}) async {
    try {
      return await pool.runTx((ctx) async {
        final tableResult = await ctx.execute(
          r'''SELECT id, restaurant_id FROM tables WHERE id = $1''',
          parameters: [tableId],
        );
        if (tableResult.isEmpty) throw Exception('Table not found');

        final restaurantId = tableResult.first[1].toString();
        final orderId = const Uuid().v4();

        await ctx.execute(
          r'''
          INSERT INTO orders (order_id, table_id, restaurant_id, status, session_id)
          VALUES ($1, $2, $3, 'new', $4)
          ''',
          parameters: [orderId, tableId, restaurantId, sessionId],
        );

        return OrderModel(orderId: orderId, status: 'new', items: const []);
      });
    } catch (e, st) {
      _log.severe('Error in createOrder', e, st);
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    try {
      return await pool.withConnection((connection) async {
        final orderResult = await connection.execute(
          r'''SELECT order_id, status, table_id, restaurant_id, waiter_id, chef_id FROM orders WHERE order_id = $1''',
          parameters: [orderId],
        );
        if (orderResult.isEmpty) return null;

        final orderRow = orderResult.first.toColumnMap();

        final itemsResult = await connection.execute(
          r'''
          SELECT oi.dish_id, oi.quantity, oi.status, oi.comment, oi.course, oi.serve_at,
                 d.id as dish_table_id, d.name, d.description, d.price, d.weight, d.image_urls, d.is_available
          FROM order_items oi JOIN dishes d ON oi.dish_id = d.id
          WHERE oi.order_id = $1
          ''',
          parameters: [orderId],
        );

        final items = <OrderItem>[];
        for (final row in itemsResult) {
          final itemMap = row.toColumnMap();
          final price = double.tryParse(itemMap['price'].toString()) ?? 0.0;
          final dish = DishModel(
            id: (itemMap['dish_table_id'] as int).toString(),
            name: itemMap['name'] as String,
            description: itemMap['description'] as String? ?? '',
            price: price,
            weight: itemMap['weight'] as String? ?? '',
            imageUrls:
                (itemMap['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
            isAvailable: itemMap['is_available'] as bool,
          );
          items.add(
            OrderItemModel(
              dishId: itemMap['dish_id'] as int,
              quantity: itemMap['quantity'] as int,
              status: itemMap['status'] as String,
              comment: itemMap['comment'] as String?,
              course: itemMap['course'] as int? ?? 1,
              serveAt: itemMap['serve_at'] as DateTime?,
              dish: dish,
            ),
          );
        }

        return OrderModel(
          orderId: orderRow['order_id'] as String,
          status: orderRow['status'] as String,
          items: items,
          waiterId: orderRow['waiter_id'] as String?,
          chefId: orderRow['chef_id'] as String?,
        );
      });
    } catch (e, st) {
      _log.severe('Error in getOrder', e, st);
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<void> diffAndSyncItems(
      String orderId, List<OrderItem> items, AuthPayload actor) async {
    try {
      await pool.runTx((ctx) async {
        final dbItemsResult = await ctx.execute(
          r'''SELECT dish_id, quantity, status FROM order_items WHERE order_id = $1''',
          parameters: [orderId],
        );

        final dbItems = <int, Map<String, dynamic>>{};
        for (final row in dbItemsResult) {
          final map = row.toColumnMap();
          dbItems[map['dish_id'] as int] = {
            'quantity': map['quantity'] as int,
            'status': map['status'] as String,
          };
        }

        final clientItems = <int, OrderItem>{};
        for (final item in items) {
          clientItems[item.dishId] = item;
        }

        final itemsToDelete = <int>[];
        for (final dbDishId in dbItems.keys) {
          if (!clientItems.containsKey(dbDishId)) {
            final status = dbItems[dbDishId]!['status'] as String?;
            if (status == 'new' || status == 'pending_confirmation') {
              itemsToDelete.add(dbDishId);
            }
          }
        }
        if (itemsToDelete.isNotEmpty) {
          await ctx.execute(
            Sql.named(
                'DELETE FROM order_items WHERE order_id = @orderId AND dish_id'
                ' = ANY(@dishIds)'),
            parameters: {
              'orderId': orderId,
              'dishIds': itemsToDelete,
            },
          );
        }

        for (final clientItem in items) {
          final dishId = clientItem.dishId;
          if (dbItems.containsKey(dishId)) {
            final dbItem = dbItems[dishId]!;
            final status = dbItem['status'] as String?;
            if (status == 'new' || status == 'pending_confirmation') {
              if (dbItem['quantity'] != clientItem.quantity ||
                  dbItem['comment'] != clientItem.comment) {
                await ctx.execute(
                  r'''UPDATE order_items SET quantity = $1, comment = $2, course = $3, serve_at = $4 WHERE order_id = $5 AND dish_id = $6''',
                  parameters: [
                    clientItem.quantity,
                    clientItem.comment,
                    clientItem.course,
                    clientItem.serveAt,
                    orderId,
                    dishId
                  ],
                );
              }
            }
          } else {
            await ctx.execute(
              r'''
              INSERT INTO order_items (order_id, dish_id, quantity, status, created_at, comment, course, serve_at)
              VALUES ($1, $2, $3, 'pending_confirmation', CURRENT_TIMESTAMP, $4, $5, $6)
              ''',
              parameters: [
                orderId,
                dishId,
                clientItem.quantity,
                clientItem.comment,
                clientItem.course,
                clientItem.serveAt,
              ],
            );
          }
        }
      });
    } catch (e, st) {
      _log.severe('Error in diffAndSyncItems', e, st);
      throw Exception('Failed to sync order items: $e');
    }
  }

  @override
  Future<void> bulkInsertItems(String orderId, List<OrderItem> items) async {
    try {
      await pool.runTx((ctx) async {
        for (final item in items) {
          await ctx.execute(
            r'''
            INSERT INTO order_items (order_id, dish_id, quantity, status, created_at, comment, course, serve_at)
            VALUES ($1, $2, $3, 'pending_confirmation', CURRENT_TIMESTAMP, $4, $5, $6)
            ''',
            parameters: [
              orderId,
              item.dishId,
              item.quantity,
              item.comment,
              item.course,
              item.serveAt,
            ],
          );
        }
      });
    } catch (e, st) {
      _log.severe('Error in bulkInsertItems', e, st);
      throw Exception('Failed to bulk insert order items: $e');
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String? actorId,
  }) async {
    try {
      await pool.runTx((ctx) async {
        final result = await ctx.execute(
          r'''UPDATE orders SET status = $1 WHERE order_id = $2''',
          parameters: [newStatus, orderId],
        );
        if (result.affectedRows == 0) throw Exception('Order not found');

        await ctx.execute(
          r'''
          INSERT INTO order_status_history (order_id, status, changed_by_user_id)
          VALUES ($1, $2, $3)
          ''',
          parameters: [orderId, newStatus, actorId],
        );
      });
    } catch (e, st) {
      _log.severe('Error in updateOrderStatus', e, st);
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<Order?> findActiveOrderByTable(String tableId) async {
    final result = await pool.withConnection((conn) => conn.execute(
          r'''
          SELECT order_id FROM orders 
          WHERE table_id = $1 AND status NOT IN ('completed', 'canceled')
          ORDER BY created_at DESC LIMIT 1
          ''',
          parameters: [tableId],
        ));
    if (result.isEmpty) return null;
    final orderId = result.first.toColumnMap()['order_id'] as String;
    return getOrder(orderId);
  }

  @override
  Future<String?> findActiveOrderIdBySession(String sessionId) async {
    final result = await pool.withConnection((conn) => conn.execute(
          r'''
          SELECT order_id FROM orders 
          WHERE session_id = $1 AND status NOT IN ('completed', 'canceled')
          ORDER BY created_at DESC LIMIT 1
          ''',
          parameters: [sessionId],
        ));
    if (result.isEmpty) return null;
    return result.first.toColumnMap()['order_id'] as String;
  }

  @override
  Future<void> updateSessionId(String orderId, String sessionId) async {
    try {
      await pool.withConnection((conn) => conn.execute(
            r'''UPDATE orders SET session_id = $1 WHERE order_id = $2''',
            parameters: [sessionId, orderId],
          ));
    } catch (e, st) {
      _log.severe('Error in updateSessionId', e, st);
      throw Exception('Failed to update session ID for order: $e');
    }
  }
}
