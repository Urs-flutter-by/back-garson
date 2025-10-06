import 'package:back_garson/domain/entities/menu.dart';

/// Абстрактный репозиторий для работы с меню.
///
/// Определяет контракт для получения данных о меню.
// ignore: one_member_abstracts
abstract class MenuRepository {
  /// Получает меню для указанного [restaurantId].
  ///
  /// Возвращает [Future] с объектом [Menu].
  Future<Menu> getMenuByRestaurantId(String restaurantId);
}
