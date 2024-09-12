import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mango/chat/message_enum.dart';
import 'package:mango/chat/model/model_chat.dart';
import 'package:mango/chat/model/model_message.dart';
import 'package:mango/chat/model/model_user.dart';

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final String documentId;

  ChatRepository({
    required this.firestore,
    required this.auth,
    required this.storage,
    required this.documentId,
  });

  Stream<List<Chatmodel>> getChatList({
    required UserModel currentUserModel,
  }) {
    return firestore
        .collection('users')
        .doc(currentUserModel.uid)
        .collection('chats')
        .where('userList', arrayContains: currentUserModel.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Chatmodel> chatModelList = [];

      for (final doc in snapshot.docs) {
        final chatData = doc.data();
        final chatId = doc.id;

        List<String> userIdList = List<String>.from(chatData['userList']);

        // 사용자 정보 가져오기
        final userModels = await Future.wait(userIdList.map((userId) async {
          final userDoc = await firestore
              .collection('users')
              .doc(userId)
              .collection('info')
              .doc('userInfo')
              .get();

          final data = userDoc.data();
          return UserModel.fromMap(data!);
        }).toList());

        final createAt = chatData['createAt'] as Timestamp;

        final chatModel = Chatmodel.fromMap(
          map: chatData,
          userList: userModels,
        ).copyWith(createAt: createAt);

        chatModelList.add(chatModel);
      }

      return chatModelList;
    }).handleError((error) {
      print('Error in getChatList: $error');
    });
  }

  Future<Chatmodel> enterChatFromFriendList({
    required String userId,
  }) async {
    try {
      final currentUserID = auth.currentUser?.uid;
      if (currentUserID == null) {
        throw Exception('Current user not authenticated');
      }

      final userModelList = await Future.wait([
        firestore
            .collection('users')
            .doc(currentUserID)
            .collection('info')
            .doc('userInfo')
            .get()
            .then((doc) {
          final data = doc.data();
          return UserModel.fromMap(data!);
        }),
        firestore
            .collection('users')
            .doc(userId)
            .collection('info')
            .doc('userInfo')
            .get()
            .then((doc) {
          final data = doc.data();
          return UserModel.fromMap(data!);
        }),
      ]);

      // 기존 채팅방 확인
      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserID)
          .collection('chats')
          .where('userList', arrayContains: userId)
          .limit(1)
          .get();

      // 채팅방이 없으면 생성
      if (querySnapshot.docs.isEmpty) {
        final newChatModel = await _createChat(userModelList: userModelList);
        return newChatModel;
      }

      return Chatmodel.fromMap(
        map: querySnapshot.docs.first.data(),
        userList: userModelList,
      );
    } catch (e) {
      print('Error in enterChatFromFriendList: $e');
      rethrow;
    }
  }

  Future<Chatmodel> _createChat({
    required List<UserModel> userModelList,
  }) async {
    final chatDocRef = firestore.collection('chats').doc();
    final chatModel = Chatmodel(
      itemid: documentId.isEmpty ? chatDocRef.id : documentId,
      id: chatDocRef.id,
      userList: userModelList,
      lastMessage: '',
      createAt: Timestamp.now(),
    );

    await firestore.runTransaction((transaction) async {
      transaction.set(chatDocRef, chatModel.toMap());

      for (var userModel in userModelList) {
        final usersChatDocRef = firestore
            .collection('users')
            .doc(userModel.uid)
            .collection('chats')
            .doc(chatDocRef.id);
        transaction.set(usersChatDocRef, chatModel.toMap());
      }
    });

    return chatModel;
  }

  Future<void> sendMessage({
    required String text,
    File? file,
    required MessageEnum messageType,
    required Chatmodel chatModel,
    required UserModel currentUserModel,
  }) async {
    try {
      final currentUserId = auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('No authenticated user found');
      }

      if (chatModel.id.isEmpty) {
        throw Exception('Chat model ID is empty');
      }

      final messageDocRef = firestore
          .collection('chats')
          .doc(chatModel.id)
          .collection('messages')
          .doc();

      final messageModel = ModelMessage(
        userId: currentUserId,
        text: text,
        type: messageType,
        createdAt: Timestamp.now(),
        messageId: messageDocRef.id,
        userModel: currentUserModel,
      );

      await firestore.runTransaction((transaction) async {
        transaction.set(messageDocRef, messageModel.toMap());

        for (final userModel in chatModel.userList) {
          transaction.set(
            firestore
                .collection('users')
                .doc(userModel.uid)
                .collection('chats')
                .doc(chatModel.id),
            chatModel.copyWith(lastMessage: text, createAt: Timestamp.now()).toMap(),
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<ModelMessage>> getMessageList({
    required String chatId,
    String? lastMessageId,
    String? firstMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt')
          .limitToLast(20);

      if (lastMessageId != null) {
        final lastDocRef = await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(lastMessageId)
            .get();
        query = query.startAfterDocument(lastDocRef);
      } else if (firstMessageId != null) {
        final firstDocRef = await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(firstMessageId)
            .get();
        query = query.endBeforeDocument(firstDocRef);
      }

      final snapshot = await query.get();
      return await Future.wait(snapshot.docs.map((messageDoc) async {
        final userModel = await firestore
            .collection('users')
            .doc(messageDoc.data()['userId'])
            .get()
            .then((value) => UserModel.fromMap(value.data()!));
        return ModelMessage.fromMap(messageDoc.data(), userModel);
      }).toList());
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }
}
