import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/message_model.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object?> get props => [];
}

class ChatDetailLoading extends ChatDetailState {}

class ChatDetailLoaded extends ChatDetailState {
  final List<Message> messages;
  final bool? ratingExists;

  const ChatDetailLoaded(this.messages, {this.ratingExists});

  @override
  List<Object?> get props => [messages, ratingExists];
}

class ChatDetailSending extends ChatDetailState {
  final List<Message> messages;
  final bool? ratingExists;

  const ChatDetailSending(this.messages, {this.ratingExists});

  @override
  List<Object?> get props => [messages, ratingExists];
}

class ChatDetailSubmittingRating extends ChatDetailState {
  final List<Message> messages;
  final bool? ratingExists;

  const ChatDetailSubmittingRating(this.messages, {this.ratingExists});

  @override
  List<Object?> get props => [messages, ratingExists];
}

class ChatDetailError extends ChatDetailState {
  final String message;

  const ChatDetailError(this.message);

  @override
  List<Object?> get props => [message];
}