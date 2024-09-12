import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mango/screens/screen_modelCreate.dart';
import '../chat/providers/chat_provider.dart';
import '../models/model_heart.dart';
import '../models/model_provider.dart';
import 'package:provider/provider.dart';
import '../tabs/tab_fit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailScreen extends StatelessWidget {
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Product;
    final heartProvider = Provider.of<HeartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '아이템 상세',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이템 이미지를 표시하는 부분
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(item.images[0]), // 첫 번째 이미지를 사용하여 이미지 표시
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 아이템 제목을 표시하는 부분
              Text(
                item.title,
                style: TextStyle(
                  color: Color(0xFF111416),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // 아이템 가격을 표시하는 부분
              Text(
                '${_formatPrice(item.price.toInt())}원',
                style: TextStyle(
                  color: Color(0xFF111416),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              // 아이템 설명 타이틀을 표시하는 부분
              Text(
                '아이템에 대한 설명',
                style: TextStyle(
                  color: Color(0xFF111416),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // 아이템 설명을 표시하는 부분
              Text(
                item.description,
                style: TextStyle(
                  color: Color(0xFF111416),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              // 사이즈 옵션을 표시하는 부분
              Row(
                children: item.size.split(',').map((size) => _buildSizeOption(size)).toList(),
              ),
              SizedBox(height: 24),
              // 모델 피팅하기 버튼을 표시하는 부분
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModelCreateScreen(), // TabFit 대신 ScreenModelCreate로 변경
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  child: Center(
                    child: Text(
                      '모델 피팅하기',
                      style: TextStyle(
                        color: Color(0xFF111416),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD9D9D9)),
                  ),
                ),
              ),

              SizedBox(height: 24),
              // 사용자 정보를 표시하는 부분
              _buildUserInfo(item), // item을 전달
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 찜하기 아이콘
                  Consumer<HeartProvider>(
                    builder: (context, heartProvider, child) {
                      final isFavorite = heartProvider.isHeartItem(item);
                      return IconButton(
                        onPressed: () {
                          if (isFavorite) {
                            heartProvider.removeHeartItem(user!.uid, item);
                          } else {
                            heartProvider.addHeartItem(user!.uid, item);
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8), // 아이콘과 버튼 사이의 간격
                  // 채팅하기 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final itemUserId = item.userId;
                          print('itemUserId : ' + itemUserId);

                          // ChatNotifier 인스턴스를 가져와서 메서드 호출
                          final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);

                          // userId가 null이 아니고 비어 있지 않은지 확인
                          if (itemUserId == null || itemUserId.isEmpty) {
                            throw Exception('Item User ID is empty or null');
                          }

                          final chatModel = await chatNotifier.enterChatFromFriendList(
                              userId: itemUserId);

                          // 채팅 화면으로 이동
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: chatModel,
                          );
                        } catch (e) {
                          // 에러 처리: 문제의 원인을 로그로 출력
                          print('Error creating chat: $e');
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: ShapeDecoration(
                          color: Color(0xFFF9C63D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '채팅하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 사용자 정보를 표시하는 메서드
  Widget _buildUserInfo(Product item) { // item을 매개변수로 받음
    final String itemUserId = item.userId;  // 상품을 올린 사용자의 ID

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(itemUserId)  // 현재 로그인된 사용자가 아닌, 상품을 올린 사용자의 정보 가져오기
          .collection('info')
          .doc('userInfo')
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('사용자 정보를 불러오지 못했습니다.');
        }

        final userData = snapshot.data!;
        final String userName = userData['name'] ?? 'Unknown';
        final String profileImageUrl = userData['profileImage'] ?? '';
        final String userJoinDate = userData['joinYear'] ?? 'Unknown'; // 가입 연도 불러오기

        return Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: Color(0xFFD9D9D9),
                shape: OvalBorder(),
                image: profileImageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(profileImageUrl),
                  fit: BoxFit.cover,
                )
                    : DecorationImage(
                  image: AssetImage('assets/images/profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Color(0xFF111416),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$userJoinDate년에 가입함',
                  style: TextStyle(
                    color: Color(0xFF637787),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 가격을 형식화하는 메서드
  String _formatPrice(int price) {
    return numberFormat.format(price);
  }

  // 사이즈 옵션을 빌드하는 함수
  Widget _buildSizeOption(String size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 42.39,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDBE0E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          size,
          style: TextStyle(
            color: Color(0xFF111416),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
