import 'package:back_garson/domain/entities/waiter_request.dart';

class WaiterRequestModel extends WaiterRequest {
  WaiterRequestModel({
    required super.requestId,
    required super.message,
    required super.timestamp,
    super.status = 'new', // Значение по умолчанию
    super.confirmedAt,
    super.completedAt,
  });

  factory WaiterRequestModel.fromJson(Map<String, dynamic> json) {
    return WaiterRequestModel(
      requestId: json['requestId'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'new',
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}
