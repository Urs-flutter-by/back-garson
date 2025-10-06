import 'package:back_garson/domain/entities/category.dart';

/// Сущность меню.
///
/// Представляет собой меню, состоящее из списка категорий блюд.
class Menu {
  /// Создает экземпляр [Menu].
  Menu({required this.categories});

  /// Список категорий блюд, входящих в меню.
  final List<Category> categories;
}
