import 'package:back_garson/data/models/category_model.dart';
import 'package:back_garson/data/models/dish_model.dart';
import 'package:back_garson/data/models/menu_model.dart';
import 'package:back_garson/domain/entities/menu.dart';
import 'package:back_garson/domain/repositories/menu_repository.dart';
import 'package:postgres/postgres.dart';

class MenuRepositoryImpl implements MenuRepository {
  final Pool pool;

  MenuRepositoryImpl(this.pool);

  @override
  Future<Menu> getMenuByRestaurantId(String restaurantId) async {
    try {
      return await pool.withConnection((connection) async {
        // Получаем категории для ресторана
        final categoriesResult = await connection.execute(
          r'''
          SELECT id, name
          FROM categories
          WHERE id IN (
            SELECT DISTINCT category_id
            FROM dishes
            WHERE restaurant_id = $1
          )
          ''',
          parameters: [restaurantId],
        );

        final categories = <CategoryModel>[];
        for (final row in categoriesResult) {
          final categoryId = row[0].toString();
          final categoryName = row[1] as String;

          // Получаем блюда для каждой категории
          final dishesResult = await connection.execute(
            r'''
            SELECT id, name, description, price, weight, image_urls, is_available
            FROM dishes
            WHERE category_id = $1 AND restaurant_id = $2
            ''',
            parameters: [int.parse(categoryId), restaurantId],
          );

          final dishes = dishesResult.map((dishRow) {
            // Преобразуем price из строки в double, если это строка
            final priceRaw = dishRow[3];
            final price =
                priceRaw is String ? double.parse(priceRaw) : (priceRaw as num).toDouble();

            return DishModel(
              id: dishRow[0].toString(),
              name: dishRow[1]! as String,
              description: dishRow[2] as String? ?? '',
              price: price,
              weight: dishRow[4] as String? ?? '',
              imageUrls: (dishRow[5] as List<dynamic>?)?.cast<String>() ?? [],
              isAvailable: dishRow[6]! as bool,
            );
          }).toList();

          categories.add(CategoryModel(
            id: categoryId,
            name: categoryName,
            dishes: dishes,
          ));
        }

        return MenuModel(categories: categories);
      });
    } catch (e, stackTrace) {
      print('MenuRepositoryImpl: ошибка: $e\n$stackTrace');
      rethrow;
    }
  }
}
