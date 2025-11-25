import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatDetailEvent {
  final String conversationId;
  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class RefreshMessages extends ChatDetailEvent {
  final String conversationId;
  const RefreshMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatDetailEvent {
  final String conversationId;
  final String text;

  const SendMessage({
    required this.conversationId,
    required this.text,
  });

  @override
  List<Object?> get props => [conversationId, text];
}