import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';

import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    on<LoadBuyingConversations>(_onLoadBuying);
    on<LoadSellingConversations>(_onLoadSelling);
  }

  Future<void> _onLoadBuying(
      LoadBuyingConversations event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());

    try {
      final data = await chatRepository.getConversations(asBuyer: true);
      emit(ChatListLoaded(data));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onLoadSelling(
      LoadSellingConversations event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());

    try {
      final data = await chatRepository.getConversations(asBuyer: false);
      emit(ChatListLoaded(data));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}