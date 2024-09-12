import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mango/chat/message_enum.dart';
import 'package:mango/chat/model/model_message.dart';

class MessageCardWidget extends StatefulWidget {
  final ModelMessage messageModel;

  const MessageCardWidget({
    Key? key,
    required this.messageModel,
  }) : super(key: key);

  @override
  _MessageCardWidgetState createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<MessageCardWidget> {
  Widget _messageText({
    required String text,
    required MessageEnum messageType,
    required bool isMe,
  }) {
    return Text(
      text, //메시지 내용
      style: TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageModel = widget.messageModel; //전달된 메시지 모델 가져옴
    final createdAt = DateFormat.Hm().format(messageModel.createdAt.toDate()); //메시지 생성시간 "HH:MM"형식으로 포맷팅

    // 접속 중인 유저의 id
    final User? user = FirebaseAuth.instance.currentUser;
    final String? currentUserId = user?.uid;

    // 메시지 작성자의 id (true or false)
    final isMe = messageModel.userId == currentUserId;
    print('isMe: $isMe, messageUserId: ${messageModel.userId}, currentUserId: $currentUserId');


    // 메시지 디자인
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        // 내가 작성 -> 오른쪽, 상대방 작성 -> 왼쪽
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
          // 프사
            CircleAvatar(
              radius: 25,
              backgroundImage: messageModel.userModel.profileImage == null
                  ? AssetImage('assets/images/기본프사(망고.png') //기본프사설정
                  : NetworkImage(messageModel.userModel.profileImage!) as ImageProvider,
            ),
          const SizedBox(width: 5),
          // 채팅 내용
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 수평정렬 - 이름은 가장 왼쪽으로
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                      minWidth: 80,
                    ),
                    decoration: BoxDecoration(
                      // 내가 보낸건 회색, 상대가 보낸건 노란색
                      color: isMe ? Color(0xffF0F2F5) : Color(0xffffe396),
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(12),
                        topLeft: const Radius.circular(12),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                      ),
                    ),
                    // 텍스트
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: _messageText(
                      text: messageModel.text,
                      messageType: messageModel.type,
                      isMe: isMe,
                    ),
                  ),
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
