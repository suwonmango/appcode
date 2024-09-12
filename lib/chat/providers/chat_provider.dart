import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mango/chat/message_enum.dart';
import 'package:mango/chat/model/model_chat.dart';
import 'package:mango/chat/model/model_message.dart';
import 'package:mango/chat/model/model_user.dart';
import 'package:mango/chat/providers/chat_state.dart';
import 'package:mango/chat/providers/chat_repository.dart';

class ChatNotifier with ChangeNotifier {
  final ChatRepository chatRepository;
  final UserModel currentUserModel;

  ChatState _state = ChatState.init();
  ChatState get state => _state;

  ChatNotifier({
    required this.chatRepository,
    required this.currentUserModel,
  });

  // 현재 사용자 정보를 FirebaseAuth에서 가져와서 ChatNotifier를 초기화하는 메서드
  static Future<ChatNotifier> initialize(ChatRepository chatRepository) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    // Firestore에서 현재 사용자 정보를 가져옴
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('info')
        .doc('userInfo')
        .get();

    if (!userDoc.exists) {
      throw Exception('User data not found in Firestore');
    }

    final userModel = UserModel.fromMap(userDoc.data()!);
    return ChatNotifier(
      chatRepository: chatRepository,
      currentUserModel: userModel,
    );
  }

  // 채팅 리스트에서 방을 선택하여 입장하는 메서드
  void enterChatFromChatList({
    required Chatmodel chatmodel,
  }) {
    try {
      _state = _state.copyWith(model: chatmodel); // chatModel을 _state에 저장
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  // 친구 리스트에서 새 채팅방을 시작하는 메서드
  Future<Chatmodel> enterChatFromFriendList({
    required String userId,
  }) async {
    try {
      final chatModel = await chatRepository.enterChatFromFriendList(userId: userId);

      if (chatModel == null) {
        throw Exception('Failed to create or retrieve chat: chatModel is null');
      }

      _state = _state.copyWith(model: chatModel);
      notifyListeners();
      return chatModel;
    } catch (e) {
      print('Error in ChatNotifier.enterChatFromFriendList: $e');
      rethrow;
    }
  }

  // 메시지 보내기 메서드
  Future<void> sendMessage({
    String? text,
    File? file,
    required MessageEnum messageType, required Chatmodel chatModel,
  }) async {
    try {
      // chatModel이 제대로 초기화되었는지 확인
      if (_state.model == null || _state.model is! Chatmodel) {
        throw Exception("Chat model is not properly initialized.");
      }

      if (text == null || text.isEmpty) {
        throw Exception("Cannot send an empty message.");
      }

      await chatRepository.sendMessage(
        text: text,
        file: file,
        chatModel: _state.model as Chatmodel,
        currentUserModel: currentUserModel,
        messageType: messageType,
      );
    } catch (e) {
      print("Error in ChatNotifier.sendMessage: $e");
      rethrow;
    }
  }
}
