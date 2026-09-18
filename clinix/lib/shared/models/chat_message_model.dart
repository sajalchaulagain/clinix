import 'package:equatable/equatable.dart';

enum ChatSender { user, ai, system }

enum ChatMessageStatus { sending, sent, error }

/// A single chat message for Upachar Sathi / Baidyek Sathi.
class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.status = ChatMessageStatus.sent,
    this.attachmentName,
    this.isDisclaimer = false,
  });

  final String id;
  final String text;
  final ChatSender sender;
  final DateTime createdAt;
  final ChatMessageStatus status;

  /// Display name of an attached image (content stays on device until the
  /// backend upload contract is finalized).
  final String? attachmentName;

  /// System disclaimer bubbles render with a distinct style.
  final bool isDisclaimer;

  bool get isFromUser => sender == ChatSender.user;

  ChatMessageModel copyWith({
    ChatMessageStatus? status,
    String? text,
  }) {
    return ChatMessageModel(
      id: id,
      text: text ?? this.text,
      sender: sender,
      createdAt: createdAt,
      status: status ?? this.status,
      attachmentName: attachmentName,
      isDisclaimer: isDisclaimer,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        sender: ChatSender.values.firstWhere(
          (s) => s.name == json['sender'],
          orElse: () => ChatSender.system,
        ),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        status: ChatMessageStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ChatMessageStatus.sent,
        ),
        attachmentName: json['attachment_name'] as String?,
        isDisclaimer: json['is_disclaimer'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'created_at': createdAt.toIso8601String(),
        'status': status.name,
        'attachment_name': attachmentName,
        'is_disclaimer': isDisclaimer,
      };

  @override
  List<Object?> get props => [id, status];
}
