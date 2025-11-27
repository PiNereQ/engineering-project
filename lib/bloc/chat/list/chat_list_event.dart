import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadBuyingConversations extends ChatListEvent {}

class LoadSellingConversations extends ChatListEvent {}