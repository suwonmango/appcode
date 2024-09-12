import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/screen_edit.dart';
import '../screens/screen_heartlist.dart';

class TabProfile extends StatefulWidget {
  const TabProfile({super.key});

  @override
  State<TabProfile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<TabProfile> {
  String name = '';
  String region = '';
  String profileImageUrl = '';
  String joinYear = ''; //가입 연도를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('info')
          .doc('userInfo')
          .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? '';
          region = doc['region'] ?? '';
          profileImageUrl = doc['profileImage'] ?? '';
          joinYear = doc['joinYear'] ?? '';  // Firestore에서 가입 연도를 가져오기
        });
      }
    }
  }

  // 사용자 정보 위젯
  Widget _infoWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닉네임
          Text(
            name.isNotEmpty ? name : '닉네임 없음',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8), // 닉네임과 가입 연도 사이 간격 증가
          // 가입 연도 (고정 값)
          Text(
            joinYear.isNotEmpty ? '$joinYear년에 가입' : '가입 연도 없음',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.black45,
            ),
          ),
          SizedBox(height: 8), // 닉네임과 가입 연도 사이 간격 증가
          // 지역
          Text(
            region.isNotEmpty ? region : '지역 정보 없음',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 편집 및 설정 버튼
  Widget _editBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16), // 버튼 양쪽에 16여백
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => editScreen()),
              );
            },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Color(0xFFF9C63D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '프로필 편집 및 설정',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프사
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 40.0, top: 24.0, bottom: 24.0),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('assets/images/default_avatar.png') as ImageProvider<Object>?,
                  ),
                ),

                // 프사-정보 여백
                const SizedBox(width: 0),

                // 정보
                _infoWidget(),
              ]),

          // 프로필편집버튼
          _editBtn(),
          const SizedBox(height: 24),

          // 가로 선을 그리기 위해 Divider 위젯을 사용
          const Divider(
            color: Color.fromARGB(76, 153, 163, 175), // 선 색상
            thickness: 1, // 선 두께
          ),

          // 관심목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트랑 버튼 사이 공간
              children: [
                const Text(
                  '관심목록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0D141C),
                  ),
                ),
                _Fbtn(),
              ],
            ),
          ),

          // 가로선
          const Divider(
            color: Color.fromARGB(76, 153, 163, 175), // 선 색상
            thickness: 1, // 선 두께
          ),

          // 판매내역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트랑 버튼 사이 공간
              children: [
                const Text(
                  '판매내역',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0D141C),
                  ),
                ),
                _Sbtn(),
              ],
            ),
          ),

          // 가로선
          const Divider(
            color: Color.fromARGB(76, 153, 163, 175), // 선 색상
            thickness: 1, // 선 두께
          ),

          // 구매내역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트랑 버튼 사이 공간
              children: [
                const Text(
                  '구매내역',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0D141C),
                  ),
                ),
                _Pbtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 관심목록 버튼
  Widget _Fbtn() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScreenHeartList()), // ScreenHeartList로 이동
        );
      },
      icon: const Icon(
        Icons.arrow_forward,
        color: Color(0xff0D141C),
        size: 24,
      ),
    );
  }
  // 판매내역
  Widget _Sbtn() {
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('판매내역')),
        );
      },
      icon: const Icon(
        Icons.arrow_forward,
        color: Color(0xff0D141C),
        size: 24,
      ),
    );
  }

  // 구매내역
  Widget _Pbtn() {
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매내역')),
        );
      },
      icon: const Icon(
        Icons.arrow_forward,
        color: Color(0xff0D141C),
        size: 24,
      ),
    );
  }
}
