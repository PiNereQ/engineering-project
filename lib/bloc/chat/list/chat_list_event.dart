part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatListEvent {
  final String userId;
  
  const LoadConversations({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}