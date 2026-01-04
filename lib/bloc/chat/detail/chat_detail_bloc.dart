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
      final messages = await chatRepository.getMessages(event.conversationId, event.currentUserId);

      bool? buyerRatingExists;
      bool? sellerRatingExists;

      if (event.currentUserId == event.buyerId) {
        // User is buyer, check if buyer has rated
        buyerRatingExists = await chatRepository.checkIfRatingByBuyerExists(
          event.currentUserId,
          event.conversationId,
        );
      } else if (event.currentUserId == event.sellerId) {
        // User is seller, check if seller has rated
        sellerRatingExists = await chatRepository.checkIfRatingBySellerExists(
          event.currentUserId,
          event.conversationId,
        );
      }

      emit(ChatDetailLoaded(messages, buyerRatingExists: buyerRatingExists, sellerRatingExists: sellerRatingExists));

      _startAutoRefresh(event.conversationId, event.currentUserId);
    } catch (e) {
      emit(ChatDetailError(_mapChatErrorToMessage(e)));
    }
  }

  Future<void> _onRefreshMessages(
      RefreshMessages event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentBuyerRatingExists = (state as ChatDetailLoaded).buyerRatingExists;
    final currentSellerRatingExists = (state as ChatDetailLoaded).sellerRatingExists;

    try {
      final messages = await chatRepository.getMessages(event.conversationId, event.currentUserId);
      emit(ChatDetailLoaded(messages, buyerRatingExists: currentBuyerRatingExists, sellerRatingExists: currentSellerRatingExists));
    } catch (_) {}
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentMessages = (state as ChatDetailLoaded).messages;
    final currentBuyerRatingExists = (state as ChatDetailLoaded).buyerRatingExists;
    final currentSellerRatingExists = (state as ChatDetailLoaded).sellerRatingExists;
    emit(ChatDetailSending(currentMessages, buyerRatingExists: currentBuyerRatingExists, sellerRatingExists: currentSellerRatingExists));

    try {
      await chatRepository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        senderId: event.senderId,
      );

      final updatedMessages =
          await chatRepository.getMessages(event.conversationId, event.senderId);

      emit(ChatDetailLoaded(updatedMessages, buyerRatingExists: currentBuyerRatingExists, sellerRatingExists: currentSellerRatingExists));
    } catch (e) {
      emit(ChatDetailError(_mapChatErrorToMessage(e)));
    }
  }

  Future<void> _onSubmitRating(
      SubmitRating event, Emitter<ChatDetailState> emit) async {
    if (state is! ChatDetailLoaded) return;

    final currentMessages = (state as ChatDetailLoaded).messages;
    final currentBuyerRatingExists = (state as ChatDetailLoaded).buyerRatingExists;
    final currentSellerRatingExists = (state as ChatDetailLoaded).sellerRatingExists;
    emit(ChatDetailSubmittingRating(currentMessages, buyerRatingExists: currentBuyerRatingExists, sellerRatingExists: currentSellerRatingExists));

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

      // After submitting, refresh messages and set the appropriate ratingExists to true
      final updatedMessages = await chatRepository.getMessages(event.conversationId, event.ratingUserId);
      final newBuyerRatingExists = event.ratedUserIsSeller ? true : currentBuyerRatingExists;
      final newSellerRatingExists = !event.ratedUserIsSeller ? true : currentSellerRatingExists;
      emit(ChatDetailLoaded(updatedMessages, buyerRatingExists: newBuyerRatingExists, sellerRatingExists: newSellerRatingExists));
    } catch (e) {
      emit(ChatDetailError(_mapChatErrorToMessage(e)));
    }
  }

  void _startAutoRefresh(String conversationId, String currentUserId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => add(RefreshMessages(conversationId, currentUserId)),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  String _mapChatErrorToMessage(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('connection closed') ||
        msg.contains('clientexception') ||
        msg.contains('socket')) {
      return 'Nie udało się połączyć z serwerem. Spróbuj ponownie.';
    }

    if (msg.contains('timeout')) {
      return 'Przekroczono czas oczekiwania na odpowiedź.';
    }

    return 'Wystąpił błąd podczas ładowania rozmowy.';
  }
}