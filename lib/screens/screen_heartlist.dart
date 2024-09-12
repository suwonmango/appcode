import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_heart.dart';
import '../models/model_provider.dart'; // Product 모델 import
import 'package:intl/intl.dart';

class ScreenHeartList extends StatefulWidget {
  @override
  _ScreenHeartListState createState() => _ScreenHeartListState();
}

class _ScreenHeartListState extends State<ScreenHeartList> {
  late String uid;
  final NumberFormat numberFormat = NumberFormat('###,###,###,###'); // NumberFormat 객체 추가

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid') ?? '';
    });

    if (uid.isNotEmpty) {
      final heartProvider = Provider.of<HeartProvider>(context, listen: false);
      await heartProvider.fetchHeartItemsOrCreate(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heartProvider = Provider.of<HeartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      appBar: AppBar(
        title: Text('관심목록'),
        centerTitle: true, // 제목을 가운데로 설정
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
      ),
      body: heartProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : heartProvider.heartItems.isEmpty
          ? Center(child: Text('관심목록이 비어있습니다.'))
          : ListView.builder(
              itemCount: heartProvider.heartItems.length,
              itemBuilder: (context, index) {
                final item = heartProvider.heartItems[index];
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: item,
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0), // ListTile의 전체 패딩 설정
                      leading: Image.network(
                        item.images[0],
                        width: 65, // 이미지의 너비를 늘림
                        height: 100, // 이미지의 높이를 늘림
                        fit: BoxFit.cover, // 이미지가 주어진 공간에 맞게 조절되도록 설정
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0), // 제목과 가격 사이 간격
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 17, // 글씨 크기 조절
                            fontWeight: FontWeight.bold, // 글씨 굵게 설정
                          ),
                        ),
                      ),
                      subtitle: Text('${numberFormat.format(item.price)}원'),
                      trailing: InkWell(
                        onTap: () {
                          heartProvider.removeHeartItem(uid, item);
                        },
                        child: Icon(Icons.delete),
                      ),
                    ),
                    Divider(
                      color: Color(0xFFE3E3E3), // Divider의 색상 설정
                      thickness: 1.0, // Divider의 두께 설정
                      indent: 20.0, // Divider의 시작점 간격 (leading과 맞추기 위함)
                      endIndent: 20.0, // Divider의 끝점 간격 (trailing과 맞추기 위함)
                    ),
                  ],
                );
              },
      ),
    );
  }
}