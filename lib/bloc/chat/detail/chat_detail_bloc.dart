import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';

import 'chat_detail_event.dart';
import 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final ChatRepository chatRepository;
  Timer? _refreshTimer;

  ChatDetailBloc({required this.chatRepository})
      : super(ChatDetailLoading()) {
    on<LoadMessages>(_onLoadMessages);
    on<RefreshMessages>(_onRefreshMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatDetailState> emit) async {
    emit(ChatDetailLoading());

    try {
      final messages = await chatRepository.getMessages(event.conversationId);

      emit(ChatDetailLoaded(messages));

      _startAutoRefresh(event.conversationId);
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onRefreshMessages(
      RefreshMessages event, Emitter<ChatDetailState> emit) async {
    try {
      final messages = await chatRepository.getMessages(event.conversationId);
      emit(ChatDetailLoaded(messages));
    } catch (_) {}
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentMessages = (state as ChatDetailLoaded).messages;
    emit(ChatDetailSending(currentMessages));

    try {
      await chatRepository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: event.senderId,
      );

      final updatedMessages =
          await chatRepository.getMessages(event.conversationId);

      emit(ChatDetailLoaded(updatedMessages));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  void _startAutoRefresh(String conversationId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => add(RefreshMessages(conversationId)),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}