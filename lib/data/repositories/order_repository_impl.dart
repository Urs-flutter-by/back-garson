import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:uuid/uuid.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DatabaseSource database;

  OrderRepositoryImpl(this.database);

  // @override
  // Future<Order> createOrder(String tableId) async {
  //   final conn = await database.connection;
  //
  //   try {
  //     // Проверяем, существует ли столик и получаем restaurant_id
  //     final tableResult = await conn.execute(
  //       r'''
  //       SELECT t.id, t.restaurant_id
  //       FROM tables t
  //       WHERE t.id = $1
  //       ''',
  //       parameters: [int.parse(tableId)],
  //     );
  //
  //     if (tableResult.isEmpty) {
  //       throw Exception('Table not found');
  //     }
  //
  //     final restaurantId = tableResult[0][1].toString();
  //
  //     // Генерируем уникальный orderId
  //     final orderId = const Uuid().v4();
  //
  //     // Создаём новый заказ
  //     final orderResult = await conn.execute(
  //       r'''
  //       INSERT INTO orders (order_id, table_id, restaurant_id, status)
  //       VALUES ($1, $2, $3, 'new')
  //       RETURNING order_id
  //       ''',
  //       parameters: [orderId, int.parse(tableId), int.parse(restaurantId)],
  //     );
  //
  //     if (orderResult.isEmpty) {
  //       throw Exception('Failed to create order');
  //     }
  //
  //     return OrderModel(
  //       orderId: orderId,
  //       items: [],
  //     );
  //   } catch (e) {
  //     throw Exception('Failed to create order: $e');
  //   } finally {
  //     await conn.close();
  //   }
  // }
  @override
  Future<Order> createOrder(String tableId) async {
    final conn = await database.connection;
    try {
      // Проверяем, существует ли столик
      final tableResult = await conn.execute(
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

      final orderResult = await conn.execute(
        r'''
      INSERT INTO orders (order_id, table_id, restaurant_id, status)
      VALUES ($1, $2, $3, 'new')
      RETURNING order_id
      ''',
        parameters: [orderId, tableId, int.parse(restaurantId)],
      );

      if (orderResult.isEmpty) {
        throw Exception('Failed to create order');
      }

      return OrderModel(orderId: orderId, items: []);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    } finally {
      await conn.close();
    }
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final conn = await database.connection;

    try {
      final orderResult = await conn.execute(
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

      final itemsResult = await conn.execute(
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

        //('🔍 Получение блюда: dishId=$dishId');
        final dishResult = await conn.execute(
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
            dishId: dishId.toString(),
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
    } catch (e) {
      throw Exception('Failed to get order: $e');
    } finally {
      await conn.close();
    }
  }

  @override
  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    final conn = await database.connection;

    try {
      await conn.runTx((ctx) async {
        // Проверяем существование заказа
        final orderResult = await ctx.execute(
          r'''
        SELECT table_id, restaurant_id
        FROM orders
        WHERE order_id = $1
        ''',
          parameters: [orderId],
        );

        if (orderResult.isEmpty) {
          // print("⚠️ Заказ с orderId=$orderId не найден");
          throw Exception('Order not found');
        }

        // Получаем все существующие элементы заказа (не только "new")
        final existingItemsResult = await ctx.execute(
          r'''
        SELECT dish_id, quantity, status, comment, course, serve_at
        FROM order_items
        WHERE order_id = $1
        ''',
          parameters: [orderId],
        );

        final existingItems = <String, Map<String, dynamic>>{};
        for (final row in existingItemsResult) {
          final dishId = row[0].toString();
          existingItems[dishId] = {
            'quantity': row[1] as int,
            'status': row[2] as String,
            'comment': row[3] as String?,
            'course': row[4] as int,
            'serve_at': row[5] as DateTime?,
          };
        }


        for (final item in items) {
          final dishId = int.parse(item.dishId);
          final quantity = item.quantity;
          final comment = item.comment;
          final course = item.course;
          final serveAt = item.serveAt;

          // Проверяем существование блюда
          final dishExists = await ctx.execute(
            r'''
          SELECT id FROM dishes WHERE id = $1
          ''',
            parameters: [dishId],
          );

          if (dishExists.isEmpty) {
            // print("⚠️ Блюдо с id=$dishId не найдено");
            throw Exception('Dish with id $dishId not found');
          }

          // Валидация курса
          if (course < 1 || course > 10) {
            // print("⚠️ Неверный курс: course=$course, должен быть 1–10");
            throw Exception('Course must be between 1 and 10');
          }

          if (existingItems.containsKey(item.dishId)) {
            final existing = existingItems[item.dishId]!;
            final existingStatus = existing['status'] as String;

            if (existingStatus == 'new') {

              await ctx.execute(
                r'''
              UPDATE order_items
              SET 
                quantity = $1,
                comment = $2,
                course = $3,
                serve_at = $4,
                created_at = CURRENT_TIMESTAMP
              WHERE order_id = $5 AND dish_id = $6 AND status = 'new'
              ''',
                parameters: [
                  quantity,
                  comment,
                  course,
                  serveAt,
                  orderId,
                  dishId,
                ],
              );
            } else {
              // print(
              //     "⚠️ Элемент с dishId=$dishId имеет статус $existingStatus, пропускаем");
              continue;
            }
          } else {
            // print(
            //     "📥 Вставка нового элемента: orderId=$orderId, dishId=$dishId, "
            //         "quantity=$quantity, comment=$comment, course=$course, serveAt=$serveAt");
            await ctx.execute(
              r'''
            INSERT INTO order_items (
              order_id, 
              dish_id, 
              quantity, 
              status, 
              created_at, 
              comment, 
              course, 
              serve_at
            )
            VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, $5, $6, $7)
            ''',
              parameters: [
                orderId,
                dishId,
                quantity,
                'new',
                comment,
                course,
                serveAt,
              ],
            );
          }
        }
      });
    } catch (e) {
      // print("❌ Ошибка при добавлении элементов заказа: $e");
      throw Exception('Failed to add order items: $e');
    } finally {
      await conn.close();
    }
  }
}
