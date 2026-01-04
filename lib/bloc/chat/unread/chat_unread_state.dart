
part of 'chat_unread_bloc.dart';

class ChatUnreadState extends Equatable {
  final bool hasUnread;

  const ChatUnreadState(this.hasUnread);

  @override
  List<Object?> get props => [hasUnread];
}