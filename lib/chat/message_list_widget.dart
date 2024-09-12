import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mango/chat/message_card_widget.dart';
import 'package:mango/chat/providers/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/model_message.dart';
import 'model/model_user.dart';

class MessageListWidget extends StatefulWidget {
  final String chatId; // chatId를 받도록 수정

  const MessageListWidget({Key? key, required this.chatId}) : super(key: key);

  @override
  _MessageListWidgetState createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatNotifier>(context);

    // Ensure that chatProvider and chatProvider.state.model are not null
    if (chatProvider.state.model == null) {
      return Center(child: Text("채팅방 정보를 불러오지 못했습니다."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId) // widget.chatId를 사용하여 Firestore에서 데이터를 가져옴
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Firestore에서 데이터를 불러오지 못했을 때의 처리
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
        }

        // Firestore 데이터에서 메시지 목록 추출
        final messageList = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;  // 데이터를 안전하게 변환

          if (data == null) {
            return null;  // 만약 데이터가 없으면 null을 반환
          }

          final userId = data['userId'] ?? '';
          final userModel = chatProvider.state.model.userList.firstWhere(
                (user) => user.uid == userId,
            orElse: () => UserModel.init(),  // 조건을 만족하는 요소가 없을 때 기본값을 반환
          );

          return ModelMessage.fromMap(data, userModel);
        }).whereType<ModelMessage>().toList();  // null 값 필터링

        // 메시지가 없을 경우 처리
        if (messageList.isEmpty) {
          return Center(child: Text("메시지가 없습니다."));
        }

        return ListView.builder(
          reverse: true,
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            return MessageCardWidget(messageModel: messageList[index]);
          },
        );
      },
    );
  }
}
