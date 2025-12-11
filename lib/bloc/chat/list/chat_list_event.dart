import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadBuyingConversations extends ChatListEvent {
  final String userId;
  
  const LoadBuyingConversations({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

class LoadSellingConversations extends ChatListEvent {
  final String userId;
  
  const LoadSellingConversations({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}