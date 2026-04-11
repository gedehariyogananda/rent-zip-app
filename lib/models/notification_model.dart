class NotificationModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? message;
  final int? orderId;
  final Map<String, dynamic>? order;
  final bool? isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.message,
    this.orderId,
    this.order,
    this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      orderId: json['order_id'] as int?,
      order: json['order'] as Map<String, dynamic>?,
      isRead: json['is_read'] is int
          ? json['is_read'] == 1
          : json['is_read'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'order_id': orderId,
      'order': order,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
