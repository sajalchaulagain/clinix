import 'package:equatable/equatable.dart';

enum AppNotificationType {
  reminder,
  bloodRequest,
  bloodAvailability,
  system,
  aiResult,
  appointment,
}

class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// Optional routing data, e.g. {'route': '/blood', 'blood_group': 'O+'}.
  /// The backend populates this when pushes are wired up.
  final Map<String, dynamic>? payload;

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        payload: payload,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String? ?? '',
        type: AppNotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AppNotificationType.system,
        ),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isRead: json['is_read'] as bool? ?? false,
        payload: json['payload'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'payload': payload,
      };

  @override
  List<Object?> get props => [id, isRead];
}
