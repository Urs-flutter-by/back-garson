class WaiterRequest {
  final String requestId;
  final String message;
  final DateTime timestamp;
  final String status;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  WaiterRequest({
    required this.requestId,
    required this.message,
    required this.timestamp,
    this.status = 'new',
    this.confirmedAt,
    this.completedAt,
  });
}
