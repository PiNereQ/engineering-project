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
    on<SubmitRating>(_onSubmitRating);
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatDetailState> emit) async {
    emit(ChatDetailLoading());

    try {
      final messages = await chatRepository.getMessages(event.conversationId);

      bool? ratingExists;
      if (event.raterId != null) {
        ratingExists = await chatRepository.checkIfRatingByBuyerExists(
          event.raterId!,
          event.conversationId,
        );
      }

      emit(ChatDetailLoaded(messages, ratingExists: ratingExists));

      _startAutoRefresh(event.conversationId);
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onRefreshMessages(
      RefreshMessages event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentRatingExists = (state as ChatDetailLoaded).ratingExists;

    try {
      final messages = await chatRepository.getMessages(event.conversationId);
      emit(ChatDetailLoaded(messages, ratingExists: currentRatingExists));
    } catch (_) {}
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentMessages = (state as ChatDetailLoaded).messages;
    final currentRatingExists = (state as ChatDetailLoaded).ratingExists;
    emit(ChatDetailSending(currentMessages, ratingExists: currentRatingExists));

    try {
      await chatRepository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: event.senderId,
      );

      final updatedMessages =
          await chatRepository.getMessages(event.conversationId);

      emit(ChatDetailLoaded(updatedMessages, ratingExists: currentRatingExists));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onSubmitRating(
      SubmitRating event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentMessages = (state as ChatDetailLoaded).messages;
    final currentRatingExists = (state as ChatDetailLoaded).ratingExists;
    emit(ChatDetailSubmittingRating(currentMessages, ratingExists: currentRatingExists));

    try {
      await chatRepository.submitRating(
        conversationId: event.conversationId,
        ratedUserId: event.ratedUserId,
        ratingUserId: event.ratingUserId,
        ratedUserIsSeller: event.ratedUserIsSeller,
        ratingStars: event.ratingStars,
        ratingValue: event.ratingValue,
        ratingComment: event.ratingComment,
      );

      // After submitting, refresh messages and set ratingExists to true
      final updatedMessages = await chatRepository.getMessages(event.conversationId);
      emit(ChatDetailLoaded(updatedMessages, ratingExists: true));
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