import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String type;
  final String? senderId;
  final String? senderUsername;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  

  const Message({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.senderId,
    required this.senderUsername, 
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        type,
        senderId,
        text,
        timestamp,
        isRead,
      ];

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      type: json['message_type'] as String,
      senderId: json['sender_id'],
      senderUsername: json['sender_username'],
      text: json['content'] as String,
      timestamp: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] == 1 ? true : false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'type': type,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? type,
    String? senderId,
    String? senderUsername,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}