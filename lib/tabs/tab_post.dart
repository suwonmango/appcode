import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mango/tabs/tab_fit.dart';
import 'package:mango/models/model_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 추가

import '../chat/providers/chat_repository.dart';
import '../screens/screen_index.dart';

// TabPost 클래스 - 중고 물품을 게시하는 화면
class TabPost extends StatefulWidget {
  final Function(String documentId)? onDocumentIdCreated;

  TabPost({this.onDocumentIdCreated});

  @override
  _TabPostState createState() => _TabPostState();
}

// _TabPostState 클래스 - TabPost의 상태를 관리하는 클래스
class _TabPostState extends State<TabPost> {
  // 텍스트 필드 컨트롤러
  final TextEditingController _titleTextEditingController = TextEditingController();
  final TextEditingController _priceTextEditingController = TextEditingController();
  final TextEditingController _contentTextEditingController = TextEditingController();
  final TextEditingController _sizeTextEditingController = TextEditingController();
  final TextEditingController _genderTextEditingController = TextEditingController();

  // 선택된 카테고리와 이미지 URL 리스트
  String _selectedCategory = '빅사이즈';
  List<String> _selectedImageUrls = [];

  String? _documentId; // 새 문서의 ID를 저장할 변수


  @override
  void dispose() {
    // 텍스트 필드 컨트롤러 해제
    _titleTextEditingController.dispose();
    _priceTextEditingController.dispose();
    _contentTextEditingController.dispose();
    _sizeTextEditingController.dispose();
    _genderTextEditingController.dispose();
    super.dispose();
  }

  // 중고 물품 추가 함수
  Future<void> _addArticle() async {

    final userId = FirebaseAuth.instance.currentUser?.uid; // 현재 사용자 ID 가져오기
    if (userId == null) {
      Fluttertoast.showToast(
        msg: "로그인 후 이용해주세요.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_selectedImageUrls.isEmpty) {
      // 선택된 이미지가 없는 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("중고 물품 사진을 1장 이상 등록해주세요."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(milliseconds: 2000),
          margin: EdgeInsets.only(
              bottom: 50, // 하단 여백을 50으로 설정 (적절히 조정 가능)
              right: 10,
              left: 10),
        ),
      );
      return;
    }
    if (_selectedImageUrls.length > 5) {
      // 선택된 이미지가 5장을 초과하는 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("사진은 최대 5장 까지 등록 가능합니다."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(milliseconds: 2000),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100, right: 10, left: 10),
        ),
      );
      return;
    }

    // Firestore에 업로드할 이미지 URL 리스트 생성
    List<String> uploadUrls = [];
    for (String imageUrl in _selectedImageUrls) {
      uploadUrls.add(imageUrl);
    }

    // Firestore에 새 문서 추가하고, 문서 ID 얻기
    DocumentReference docRef = await FirebaseFirestore.instance.collection('product').add({
      'title': _titleTextEditingController.text,
      'description': _contentTextEditingController.text,
      'price': double.parse(_priceTextEditingController.text),
      'category': _selectedCategory,
      'images': uploadUrls,
      'size': _sizeTextEditingController.text,
      'gender': _genderTextEditingController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId, // 작성자 정보 추가
    });

    // 문서 ID 저장
    _documentId = docRef.id;

    // FirebaseStorage 인스턴스 생성
    final FirebaseStorage storage = FirebaseStorage.instance;

    // ChatRepository 인스턴스 생성 시 documentId 제공
    final chatRepository = ChatRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      storage: storage,
      documentId: _documentId!, // _documentId가 null이 아님을 보장
    );

    if (widget.onDocumentIdCreated != null) {
      widget.onDocumentIdCreated!(_documentId!);
    }

    // 성공 메시지 표시
    Fluttertoast.showToast(
        msg: "새로운 중고물품을 등록하였습니다.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => IndexScreen(initialIndex: 0)),
    );
  }

  // 옷장에서 이미지 선택 함수
  Future<void> _pickFromWardrobe() async {
    // TabFit 화면으로 이동하여 다중 선택 모드 활성화
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabFit(isMultiSelectMode: true)),
    );
    if (data != null && data['imageUrls'] != null) {
      setState(() {
        _selectedImageUrls.addAll(List<String>.from(data['imageUrls'])); // 선택된 이미지 URL 추가
      });
    }
  }

  // 사진 미리보기 위젯 생성
  Widget _photoPreviewWidget() {
    if (_selectedImageUrls.isEmpty) return Container();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _selectedImageUrls.map((imageUrl) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl), // 네트워크 이미지
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red), // 삭제 버튼
                  onPressed: () {
                    setState(() {
                      _selectedImageUrls.remove(imageUrl); // 선택된 이미지 URL 삭제
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 게시물 작성 화면 위젯
  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickFromWardrobe, // 옷장에서 이미지 선택 함수 호출
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: ShapeDecoration(
                      color: Color(0xFFE8EDF2),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.50,
                          color: Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Icon(Icons.photo_album, color: Colors.grey), // 앨범 아이콘
                  ),
                ),
                Expanded(child: _photoPreviewWidget()) // 사진 미리보기 위젯
              ],
            ),
            SizedBox(height: 30),
            Text(
              '제목',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _titleTextEditingController, // 제목 입력 필드 컨트롤러
                  decoration: InputDecoration(
                    hintText: '제목을 입력해주세요',
                    border: InputBorder.none,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '카테고리',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: <String>[
                    '빅사이즈',
                    '상의',
                    '팬츠',
                    '신발',
                    '기타'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '가격',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _priceTextEditingController, // 가격 입력 필드 컨트롤러
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '가격을 입력해주세요',
                    border: InputBorder.none,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '설명',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 144,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: TextField(
                controller: _contentTextEditingController, // 설명 입력 필드 컨트롤러
                decoration: InputDecoration(
                  hintText: '상품 설명을 입력해주세요',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '사이즈',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _sizeTextEditingController, // 사이즈 입력 필드 컨트롤러
                  decoration: InputDecoration(
                    hintText: '사이즈 입력',
                    border: InputBorder.none,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '성별',
              style: TextStyle(
                color: Color(0xFF0C141C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 0.09,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Color(0xFFF0F2F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _genderTextEditingController, // 성별 입력 필드 컨트롤러
                  decoration: InputDecoration(
                    hintText: '성별 입력',
                    border: InputBorder.none,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _addArticle, // 게시물 추가 함수 호출
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: Color(0xFFF9C63D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    '등록 완료',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF7F9FC),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 0.11,
                      letterSpacing: 0.21,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _bodyWidget(), // 게시물 작성 화면 빌드
    );
  }

  // 문서 ID를 외부에서 접근할 수 있는 함수
  String? getDocumentId() {
    return _documentId;
  }
}
