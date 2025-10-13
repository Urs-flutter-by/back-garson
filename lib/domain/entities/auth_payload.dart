import 'package:equatable/equatable.dart';

/// Полезная нагрузка, извлеченная из JWT-токена.
/// Содержит информацию об аутентифицированном пользователе.
class AuthPayload extends Equatable {
  /// Создает экземпляр [AuthPayload].
  const AuthPayload({
    required this.userId,
    required this.role,
  });

  /// Уникальный идентификатор пользователя.
  final String userId;

  /// Роль пользователя (например, 'WAITER', 'ADMIN_RESTAURANT').
  final String role;

  @override
  List<Object?> get props => [userId, role];
}
