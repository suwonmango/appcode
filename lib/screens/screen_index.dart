// screens/screen_index.dart
// 앱바 관리 밑 밑에 메뉴바
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mango/tabs/tab_fit.dart';
import 'package:mango/tabs/tab_chat.dart';
import 'package:mango/tabs/tab_home.dart';
import 'package:mango/tabs/tab_post.dart';
import 'package:mango/tabs/tab_profile.dart';


class IndexScreen extends StatefulWidget {
  final int initialIndex; // 추가된 부분

  IndexScreen({this.initialIndex = 0}); // 생성자에 초기 인덱스 설정

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // initialIndex를 사용하여 초기 탭 설정
  }

  final List<Widget> tabs = [
    TabHome(),
    TabFit(),
    TabPost(),
    TabChat(),
    TabProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        title: Image.asset(
          'assets/images/망고로고.png', // 로고 이미지 경로
          height: 43, // 이미지 높이
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [ // AppBar의 오른쪽에 아이콘을 추가하는 영역
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 아이콘을 눌렀을 때 실행할 코드
              print("알림 아이콘 클릭됨");
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedItemColor: Color(0xfff9c63d),
        unselectedItemColor: Color(0xff4f7396),
        selectedLabelStyle: TextStyle(fontSize: 12),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.straighten_outlined), label: '피팅'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: '등록'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: '프로필'),
        ],
      ),
      body: tabs[_currentIndex],
    );
  }
}
