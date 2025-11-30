import 'package:equatable/equatable.dart';

abstract class ChatUnreadEvent extends Equatable {
  const ChatUnreadEvent();

  @override
  List<Object?> get props => [];
}

class CheckUnreadStatus extends ChatUnreadEvent {}