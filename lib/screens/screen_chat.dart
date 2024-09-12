import 'package:flutter/material.dart';
import 'package:mango/chat/message_input_field_widget.dart';
import 'package:mango/chat/message_list_widget.dart';
import 'package:mango/chat/model/model_chat.dart';
import 'package:mango/chat/model/model_user.dart';

class ChatScreen extends StatelessWidget {
  static const String routeName = '/chat';

  final Chatmodel chatModel;

  const ChatScreen({Key? key, required this.chatModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = chatModel.userList.length > 1
        ? chatModel.userList[1]
        : UserModel.init();

    // chatId가 유효한지 확인
    if (chatModel.id.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Invalid chat ID.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/망고로고.png', // 로고 이미지 경로
          height: 43, // 이미지 높이
          fit: BoxFit.contain,
        ),
        leading: BackButton(
          onPressed: () {
            print("뒤로가기 아이콘 클릭됨");
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListWidget(
              chatId: chatModel.id, // chatId 전달
            ),
          ),
          MessageInputFieldWidget(
            chatModel: chatModel, // chatModel 전달
          ),
        ],
      ),
    );
  }
}