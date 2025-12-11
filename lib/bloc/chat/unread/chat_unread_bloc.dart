import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';
import 'chat_unread_event.dart';
import 'chat_unread_state.dart';

class ChatUnreadBloc extends Bloc<ChatUnreadEvent, ChatUnreadState> {
  final ChatRepository chatRepository;

  ChatUnreadBloc({required this.chatRepository})
      : super(const ChatUnreadState(false)) {
    on<CheckUnreadStatus>(_onCheckUnread);
  }

  Future<void> _onCheckUnread(
      CheckUnreadStatus event, Emitter<ChatUnreadState> emit) async {
    final hasUnread = chatRepository.hasUnreadMessages(event.userId);
    emit(ChatUnreadState(hasUnread));
  }
}