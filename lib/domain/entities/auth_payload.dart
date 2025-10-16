import 'package:equatable/equatable.dart';

/// Полезная нагрузка, извлеченная из JWT-токена.
/// Содержит информацию об аутентифицированном пользователе или госте.
class AuthPayload extends Equatable {
  /// Создает экземпляр [AuthPayload].
  const AuthPayload({
    required this.role,
    this.userId,
    this.tableId,
    this.restaurantId,
    this.sessionId,
  });

  /// Роль пользователя (например, 'WAITER', 'CUSTOMER').
  final String role;

  /// Уникальный идентификатор пользователя (для сотрудников).
  final String? userId;

  /// ID столика (для гостей).
  final String? tableId;

  /// ID ресторана (для гостей).
  final String? restaurantId;

  /// Уникальный ID сессии (для гостей).
  final String? sessionId;

  @override
  List<Object?> get props => [role, userId, tableId, restaurantId, sessionId];
}
