// models/model_auth.dart
// enum(자유)으로 상태 정의
// FirebaseAuth authClient가 실제로 파이어베이스에 연결하는 client, 이 client를 이용해 회원가입 시켜줌/ 실제 동작하는 메소드는 createUserWithEmailAndPassword
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  registerSuccess,
  registerFail,
  loginSuccess,
  loginFail
}

class FirebaseAuthProvider with ChangeNotifier {
  FirebaseAuth authClient;
  User? user;

  FirebaseAuthProvider({auth}) : authClient = auth ?? FirebaseAuth.instance;

  Future<AuthStatus> registerWithEmail(String email, String password) async {
    try {
      UserCredential credential = await authClient.createUserWithEmailAndPassword(email: email, password: password);
      return AuthStatus.registerSuccess;
    } catch (e) {
      return AuthStatus.registerFail;
    }
  }

  Future<AuthStatus> loginWithEmail(String email, String password) async {

    try {
      await authClient.signInWithEmailAndPassword(email: email, password: password).then(
              (credential) async {
            user = credential.user;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLogin', true);
            prefs.setString('email', email);
            prefs.setString('password', password);
            prefs.setString('uid', user!.uid);
          }
      );
      return AuthStatus.loginSuccess;
    } catch (e) {
      return AuthStatus.loginFail;
    }
  }

  Future<void> logout() async { //로그아웃 기능 추가/ 내부 데이터를 지우고, 파이어 베이스에 sign out 하는 것.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', false);
    prefs.setString('email', '');
    prefs.setString('password', '');
    prefs.setString('uid', '');
    user = null;
    await authClient.signOut();
  }
}
