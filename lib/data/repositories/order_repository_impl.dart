import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/data/models/order_item_model.dart';
import 'package:back_garson/data/models/order_model.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:back_garson/domain/entities/order.dart';
import 'package:back_garson/domain/entities/order_item.dart';
import 'package:back_garson/domain/repositories/order_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// Реализация OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final DatabaseSource database;

  OrderRepositoryImpl(this.database);

  @override
  Future<Order> createOrder(String tableId) async {
    final conn = await database.connection;

    // Проверяем, существует ли столик и получаем restaurant_id
    final tableResult = await conn.execute(
      r'''
      SELECT t.id, t.restaurant_id
      FROM tables t
      WHERE t.id = $1
      ''',
      parameters: [int.parse(tableId)],
    );

    if (tableResult.isEmpty) {
      throw Exception('Table not found');
    }

    final restaurantId = tableResult[0][1].toString();

    // Генерируем уникальный orderId
    final orderId = const Uuid().v4();

    // Создаём новый заказ (без элементов на этом этапе)
    final orderResult = await conn.execute(
      r'''
      INSERT INTO orders (order_id, table_id, restaurant_id, status)
      VALUES ($1, $2, $3, 'new')
      RETURNING order_id
      ''',
      parameters: [orderId, int.parse(tableId), int.parse(restaurantId)],
    );

    if (orderResult.isEmpty) {
      throw Exception('Failed to create order');
    }

    return OrderModel(
      orderId: orderId,
      items: [], // Элементы заказа пока пустые
    );
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final conn = await database.connection;

    try {
      print("🔍 Проверка заказа: orderId=$orderId");
      final orderResult = await conn.execute(
        r'''
      SELECT order_id, table_id, restaurant_id
      FROM orders
      WHERE order_id = $1
      ''',
        parameters: [orderId],
      );

      if (orderResult.isEmpty) {
        print("⚠️ Заказ с orderId=$orderId не найден");
        return null;
      }

      print("🔍 Заказ найден: order_id=${orderResult.first[0]}, table_id=${orderResult.first[1]}, restaurant_id=${orderResult.first[2]}");

      print("🔍 Запрашиваем элементы заказа: orderId=$orderId");
      final itemsResult = await conn.execute(
        r'''
      SELECT dish_id, quantity, status
      FROM order_items
      WHERE order_id = $1
      ''',
        parameters: [orderId],
      );

      final items = <OrderItem>[];
      for (final row in itemsResult) {
        final dishId = row[0] as int;
        final quantity = row[1] as int;
        final status = row[2] as String;

        print("🔍 Запрашиваем блюдо: dishId=$dishId");
        final dishResult = await conn.execute(
          r'''
        SELECT id, name, price, weight, is_available
        FROM dishes
        WHERE id = $1
        ''',
          parameters: [dishId],
        );

        if (dishResult.isEmpty) {
          print("⚠️ Блюдо с id=$dishId не найдено");
          throw Exception('Dish with id $dishId not found');
        }

        final dishRow = dishResult.first;
        print("🔍 Данные блюда: id=${dishRow[0]}, name=${dishRow[1]}, price=${dishRow[2]}, weight=${dishRow[3]}, is_available=${dishRow[4]}");
        final priceRaw = dishRow[2].toString();
        final price = double.tryParse(priceRaw);
        if (price == null) {
          print("⚠️ Неверный формат цены для dishId=$dishId: price=$priceRaw");
          throw Exception('Invalid price format for dish $dishId: $priceRaw');
        }
        final dish = DishModel(
          id: dishRow[0].toString(),
          name: dishRow[1] as String,
          description: '',
          price: price,
          weight: dishRow[3] as String,
          imageUrls: [],
          isAvailable: dishRow[4] as bool,
        );

        items.add(OrderItemModel(
          dishId: dishId.toString(),
          quantity: quantity,
          status: status,
          dish: dish,
        ));
      }

      final orderRow = orderResult.first;
      return OrderModel(
        orderId: orderRow[0] as String,
        items: items,
      );
    } catch (e) {
      print("❌ Ошибка в getOrder: orderId=$orderId, error=$e");
      throw Exception('Failed to get order: $e');
    } finally {
      print("🔌 Закрытие соединения для getOrder: orderId=$orderId");
      await conn.close();
    }
  }

  Future<void> addOrderItems(String orderId, List<OrderItem> items) async {
    final conn = await database.connection;

    try {
      await conn.runTx((ctx) async {
        print("🔍 Проверка заказа: orderId=$orderId");
        final Result orderResult = await ctx.execute(
          r'''
        SELECT table_id, restaurant_id
        FROM orders
        WHERE order_id = $1
        ''',
          parameters: [orderId],
        );

        if (orderResult.isEmpty) {
          print("⚠️ Заказ с orderId=$orderId не найден");
          throw Exception('Order not found');
        }

        print("🔍 Заказ найден: table_id=${orderResult[0][0]}, "
            "restaurant_id=${orderResult[0][1]}");

        print("🔍 Проверка существующих элементов: orderId=$orderId");
        final Result existingItemsResult = await ctx.execute(
          r'''
        SELECT dish_id, quantity
        FROM order_items
        WHERE order_id = $1 AND status = 'new'
        ''',
          parameters: [orderId],
        );

        final existingItems = <String, int>{};
        for (final row in existingItemsResult) {
          final quantity = row[1] as int;
          existingItems[row[0].toString()] = quantity;
        }
        print("🔍 Существующие элементы: $existingItems");

        for (final item in items) {
          final dishId = int.parse(item.dishId);
          final quantity = item.quantity;

          print(
              "📝 Добавление элемента: orderId=$orderId, "
                  "dishId=$dishId, quantity=$quantity");

          final dishExists = await ctx.execute(
            r'''
          SELECT id FROM dishes WHERE id = $1
          ''',
            parameters: [dishId],
          );

          if (dishExists.isEmpty) {
            print("⚠️ Блюдо с id=$dishId не найдено");
            throw Exception('Dish with id $dishId not found');
          }

          if (existingItems.containsKey(item.dishId)) {
            final newQuantity = existingItems[item.dishId]! + quantity;
            print(
                "🔄 Обновление количества: dishId=$dishId, "
                    "newQuantity=$newQuantity");
            await ctx.execute(
              r'''
            UPDATE order_items
            SET quantity = $1
            WHERE order_id = $2 AND dish_id = $3 AND status = 'new'
            ''',
              parameters: [newQuantity, orderId, dishId],
            );
          } else {
            print(
                "📥 Вставка нового элемента: orderId=$orderId, "
                    "dishId=$dishId, quantity=$quantity");
            try {
              await ctx.execute(
                r'''
              INSERT INTO order_items (order_id, dish_id, quantity, status, created_at)
              VALUES ($1, $2, $3, 'new', CURRENT_TIMESTAMP)
              ''',
                parameters: [orderId, dishId, quantity],
              );
            } catch (e) {
              print(
                  "❌ Ошибка в INSERT: orderId=$orderId, "
                      "dishId=$dishId, quantity=$quantity, error=$e");
              rethrow;
            }
          }
        }
      });
    } catch (e) {
      print("❌ Ошибка при добавлении элементов заказа: $e");
      throw Exception('Failed to add order items: $e');
    } finally {
      await conn.close();
    }
  }
}
