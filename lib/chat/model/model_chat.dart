import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mango/chat/model/model_base.dart';
import 'package:mango/chat/model/model_user.dart';

class Chatmodel extends BaseModel {
  Chatmodel({
    required super.itemid,
    required super.id,
    super.lastMessage = '',
    required super.userList,
    required super.createAt,
  });

  factory Chatmodel.init() {
    return Chatmodel(
      itemid: '',
      id: '',
      userList: [],
      createAt: Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemid': itemid,
      'id': id,
      'lastMessage': lastMessage,
      'userList': userList.map<String>((e) => e.uid).toList(),
      'createAt': createAt,
    };
  }

  factory Chatmodel.fromMap({
    required Map<String, dynamic> map,
    required List<UserModel> userList,
  }) {
    // map에서 'userList'가 null일 경우 빈 리스트를 기본값으로 설정합니다.
    return Chatmodel(
      itemid: map['itemid'] ?? '',
      id: map['id'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      userList: userList,
      createAt: map['createAt'] ?? Timestamp.now(),
    );
  }


  Chatmodel copyWith({
    String? itemid,
    String? id,
    String? lastMessage,
    List<UserModel>? userList,
    Timestamp? createAt,
  }) {
    return Chatmodel(
      itemid: itemid ?? this.itemid,
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      userList: userList ?? this.userList,
      createAt: createAt ?? this.createAt,
    );
  }
}
