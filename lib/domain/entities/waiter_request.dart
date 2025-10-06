/// Сущность запроса официанта.
///
/// Представляет собой запрос, сделанный официантом, с его идентификатором,
/// сообщением, временной меткой, статусом и временными метками подтверждения/завершения.
class WaiterRequest {
  /// Создает экземпляр [WaiterRequest].
  WaiterRequest({
    required this.requestId,
    required this.message,
    required this.timestamp,
    this.status = 'new',
    this.confirmedAt,
    this.completedAt,
  });

  /// Уникальный идентификатор запроса.
  final String requestId;

  /// Сообщение запроса.
  final String message;

  /// Временная метка создания запроса.
  final DateTime timestamp;

  /// Статус запроса (например, "new", "confirmed", "completed").
  final String status;

  /// Временная метка подтверждения запроса.
  final DateTime? confirmedAt;

  /// Временная метка завершения запроса.
  final DateTime? completedAt;
}
