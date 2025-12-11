import 'package:equatable/equatable.dart';

abstract class ChatUnreadEvent extends Equatable {
  const ChatUnreadEvent();

  @override
  List<Object?> get props => [];
}

class CheckUnreadStatus extends ChatUnreadEvent {
  final String userId;
  
  const CheckUnreadStatus({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}