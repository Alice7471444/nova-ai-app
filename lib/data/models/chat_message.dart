import 'package:equatable/equatable.dart';

enum MessageType { user, ai, system }

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
    );
  }

  @override
  List<Object?> get props => [id, content, timestamp, type];
}
