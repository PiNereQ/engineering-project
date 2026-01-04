import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/conversation_model.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    on<LoadConversations>(_onLoadConversations);
  }

  Future<void> _onLoadConversations(
      LoadConversations event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());

    try {
      final buyingData = await chatRepository.getConversations(
        asBuyer: true,
        userId: event.userId,
      );
      final sellingData = await chatRepository.getConversations(
        asBuyer: false,
        userId: event.userId,
      );
      emit(ChatListLoaded(
        buyingConversations: buyingData,
        sellingConversations: sellingData,
      ));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}