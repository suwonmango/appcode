// models/model_register.dart
// 이메일, 비밀번호, 비밀번호 확인 칸들의 값이 변경될때마다 set 메서드를 통해 Provider를 이용해 상태변화값을 알림
// notifyListeners를 이용해 상태 변경 사항을 브로드캐스팅
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RegisterModel extends ChangeNotifier {
  String email = "";
  String password = "";
  String passwordConfirm = "";
  String name = "";
  String region = "";
  File? _image;


  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  void setPasswordConfirm(String passwordConfirm) {
    this.passwordConfirm = passwordConfirm;
    notifyListeners();
  }

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void setRegion(String region) {
    this.region = region;
    notifyListeners();
  }

  // 이미지 설정 메서드
  void setImage(File image) {
    _image = image;
    print('setImage called with: $_image'); // 디버깅 로그 추가
    notifyListeners(); // 상태 변경을 알림
  }

  File? get image => _image;
}
