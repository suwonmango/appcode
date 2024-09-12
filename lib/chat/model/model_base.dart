import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_user.dart';

abstract class BaseModel {
  final String itemid; //품목 id
  final String id; //채팅방의 id
  final String lastMessage; //채팅방 가장 최근 메시지
  final List<UserModel> userList; //채팅방에 참여중인 유저id를 갖고있는 리스트
  final Timestamp createAt; //업데이트 날짜

  const BaseModel({
    required this.itemid,
    required this.id,
    this.lastMessage = '', //기본값으로 빈 문자열
    required this.userList,
    required this.createAt,
  });
}