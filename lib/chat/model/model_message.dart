import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mango/chat/message_enum.dart';
import 'package:mango/chat/model/model_user.dart';

class ModelMessage {
  final String userId;
  final String text;
  final MessageEnum type;
  final Timestamp createdAt;
  final String messageId;
  final UserModel userModel;

  ModelMessage({
    required this.userId,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.messageId,
    required this.userModel,
  });

  // 복사 메서드 (필요한 경우에만)
  ModelMessage copyWith({
    String? userId,
    String? text,
    MessageEnum? type,
    Timestamp? createdAt,
    String? messageId,
    UserModel? userModel,
  }) {
    return ModelMessage(
      userId: userId ?? this.userId,  // 오류가 나는 부분을 고쳤습니다.
      text: text ?? this.text,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      messageId: messageId ?? this.messageId,
      userModel: userModel ?? this.userModel,
    );
  }

  @override
  String toString() {
    return 'ModelMessage{userId: $userId, text: $text, type: $type, createdAt: $createdAt, messageId: $messageId, userModel: $userModel}';
  }

  // toMap 메서드
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'type': type.name,
      'createdAt': createdAt,
      'messageId': messageId,
      // 필요한 경우 userModel의 다른 필드도 추가 가능
    };
  }

  // fromMap 메서드
  factory ModelMessage.fromMap(Map<String, dynamic> map, UserModel userModel) {
    return ModelMessage(
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      messageId: map['messageId'] ?? '',
      userModel: userModel,
    );
  }
}



