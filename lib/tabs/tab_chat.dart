import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat/model/model_chat.dart';
import '../chat/model/model_user.dart';
import '../chat/providers/chat_provider.dart';
import '../screens/screen_chat.dart';

class TabChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatNotifier>(context);

    return Scaffold(
      body: StreamBuilder<List<Chatmodel>>(
        stream: chatProvider.chatRepository.getChatList(
          currentUserModel: chatProvider.currentUserModel,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chatList = snapshot.data!;

          print('Number of chat rooms: ${chatList.length}');

          if (chatList.isEmpty) {
            return Center(child: Text('채팅 목록이 없습니다.'));
          }

          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              final chatModel = chatList[index];
              final lastMessage = chatModel.lastMessage;
              final createAt = chatModel.createAt.toDate();
              final userModel = chatModel.userList.firstWhere(
                    (user) => user.uid != chatProvider.currentUserModel.uid,
                orElse: () => UserModel.init(),
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userModel.profileImage != null
                      ? NetworkImage(userModel.profileImage!) as ImageProvider
                      : AssetImage('assets/images/기본프사(망고.png'),
                ),
                title: Text(userModel.name),
                subtitle: Text(lastMessage),
                trailing: Text(_formatTimestamp(createAt)),
                onTap: () {
                  final chatProvider = Provider.of<ChatNotifier>(context, listen: false);

                  chatProvider.enterChatFromChatList(chatmodel: chatModel);  // 채팅방에 입장
                  // 채팅 아이템 클릭 시 채팅 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatModel: chatModel, // 선택된 채팅방 정보를 전달
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 1) {
      return '${timestamp.month}/${timestamp.day}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../chat/model/model_chat.dart';
// import '../chat/model/model_user.dart';
// import '../chat/providers/chat_provider.dart';
//
// class TabChat extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatNotifier>(context);
//
//     return Scaffold(
//       body: StreamBuilder<List<Chatmodel>>(
//         stream: chatProvider.chatRepository.getChatList(
//           currentUserModel: chatProvider.currentUserModel,
//         ),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           final chatList = snapshot.data!;
//
//           // 추가된 디버깅 코드: 가져온 채팅방의 수를 로그로 출력
//           print('Number of chat rooms: ${chatList.length}');
//
//           if (chatList.isEmpty) {
//             return Center(child: Text('채팅 목록이 없습니다.'));
//           }
//
//           return ListView.builder(
//             itemCount: chatList.length,
//             itemBuilder: (context, index) {
//               final chatModel = chatList[index];
//               final lastMessage = chatModel.lastMessage;
//               final createAt = chatModel.createAt.toDate();
//               final userModel = chatModel.userList.firstWhere(
//                     (user) => user.uid != chatProvider.currentUserModel.uid,
//                 orElse: () => UserModel.init(),
//               );
//
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: userModel.profileImage != null
//                       ? NetworkImage(userModel.profileImage!) as ImageProvider
//                       : AssetImage('assets/images/기본프사(망고.png'),
//                 ),
//                 title: Text(userModel.name),
//                 subtitle: Text(lastMessage),
//                 trailing: Text(_formatTimestamp(createAt)),
//                 onTap: () {
//                   // 채팅 아이템 클릭 시 처리
//                   chatProvider.enterChatFromChatList(chatmodel: chatModel);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//
//     if (difference.inDays > 1) {
//       return '${timestamp.month}/${timestamp.day}';
//     } else {
//       return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//     }
//   }
// }
