import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatDetailEvent {
  final String conversationId;
  final String? raterId;
  final String currentUserId;

  const LoadMessages(this.conversationId, this.currentUserId, {this.raterId});

  @override
  List<Object?> get props => [conversationId, raterId, currentUserId];
}

class RefreshMessages extends ChatDetailEvent {
  final String conversationId;
  final String currentUserId;
  const RefreshMessages(this.conversationId, this.currentUserId);

  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatDetailEvent {
  final String conversationId;
  final String text;
  final String senderId;

  const SendMessage({
    required this.conversationId,
    required this.text,
    required this.senderId,
  });

  @override
  List<Object?> get props => [conversationId, text, senderId];
}

class SubmitRating extends ChatDetailEvent {
  final String conversationId;
  final String ratedUserId;
  final String ratingUserId;
  final bool ratedUserIsSeller;
  final int ratingStars;
  final int ratingValue;
  final String? ratingComment;

  const SubmitRating({
    required this.conversationId,
    required this.ratedUserId,
    required this.ratingUserId,
    required this.ratedUserIsSeller,
    required this.ratingStars,
    required this.ratingValue,
    this.ratingComment,
  });

  @override
  List<Object?> get props => [conversationId, ratedUserId, ratingUserId, ratedUserIsSeller, ratingStars, ratingValue, ratingComment];
}