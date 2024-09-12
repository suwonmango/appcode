import 'package:mango/chat/model/model_chat.dart';
import '../model/model_message.dart';

class ChatState {
  final List<Chatmodel> chatList;
  final Chatmodel model;
  final List<ModelMessage> messageList;

  ChatState({
    required this.chatList,
    required this.model,
    required this.messageList,
  });

  factory ChatState.init() {
    return ChatState(
      chatList: [],
      model: Chatmodel.init(),
      messageList: [],
    );
  }

  ChatState copyWith({
    List<Chatmodel>? chatList,
    Chatmodel? model,
    List<ModelMessage>? messageList,
  }) {
    return ChatState(
      chatList: chatList ?? this.chatList,
      model: model ?? this.model,
      messageList: messageList ?? this.messageList,
    );
  }
}
