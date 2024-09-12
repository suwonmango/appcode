// screens/screen_splash.dart

// SharedPreference는 싱글톤으로 key:value의 데이터를 저장할 수 있는 패키지입니다. 로그인을 했을 경우 isLogin을 true로 해놓고, 아닐 경우 false로 저장할 예정입니다.
// 따라서 isLogin값을 가져와서 true라면 이미 로그인이 되어있는 상황이기 때문에 /index 화면으로 넘어가면 되고, false라면 로그인을 해야 하기 때문에 /login으로 보내면 됩니다.

// SharedPreference에서 값을 꺼내오는 건 CheckLogin()에서 실행되는데,
// 여기 잘 보시면 Future - await를 사용했습니다. 값을 바로 가져오지는 못하기 때문에 async(비동기)로 가져와야 합니다.

// ScreenSplash는 실행되면 initState가 실행되고 거기서 2초의 딜레이를 갖고 moveScreen()을 실행하고,
// 여기서 isLogin의 여부로 /index로 갈지 /login으로 갈지 결정됩니다. /index화면은 이미 만들었기 때문에 /login화면도 한번 만들어볼까요? -->로그인 화면
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/model_heart.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>{

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final heartProvider = Provider.of<HeartProvider>(context, listen: false);
    bool isLogin = prefs.getBool('isLogin') ?? false;
    String uid = prefs.getString('uid') ?? '';
    heartProvider.fetchHeartItemsOrCreate(uid);
    return isLogin;
  }

  void moveScreen() async {
    await checkLogin().then((isLogin){
      if(isLogin){
        Navigator.of(context).pushReplacementNamed('/index');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }


  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 2000), (){
      moveScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 스플래시 스크린 배경색 설정
      body: Center(
        child: Container(
          color: Colors.white, // 로고 이미지 배경색 설정
          child: Image.asset(
            'assets/images/망고로고.png',
            width: 150, // 원하는 너비로 설정
            height: 150, // 원하는 높이로 설정
            fit: BoxFit.contain, // 이미지를 스플래시 스크린에 맞게 조절
          ),
        ),
      ),
    );
  }
}