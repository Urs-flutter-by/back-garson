/// Сущность официанта.
///
/// Представляет собой официанта с его идентификатором, именем пользователя
/// и идентификатором ресторана.
class Waiter {
  /// Создает экземпляр [Waiter].
  Waiter({
    required this.id,
    required this.username,
    required this.restaurantId,
  });

  /// Уникальный идентификатор официанта.
  final String id;

  /// Имя пользователя официанта.
  final String username;

  /// Идентификатор ресторана, в котором работает официант.
  final String restaurantId;
}
