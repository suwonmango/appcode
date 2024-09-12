import 'package:flutter/material.dart';

class ModelCreateScreen extends StatefulWidget {
  @override
  _ModelCreateScreenState createState() => _ModelCreateScreenState();
}

class _ModelCreateScreenState extends State<ModelCreateScreen> {
  bool _isPageLoading = true; // 페이지 로딩 상태를 관리하는 변수
  bool _isModelLoading = false; // 모델 이미지 로딩 상태를 관리하는 변수
  bool _isItemsVisible = false; // 상품 목록의 가시성을 제어하는 변수
  String _modelImagePath = 'assets/images/model.png'; // 현재 모델 이미지 경로

  @override
  void initState() {
    super.initState();
    _simulatePageLoading(); // 페이지 로딩을 시뮬레이션
  }

  Future<void> _simulatePageLoading() async {
    await Future.delayed(Duration(seconds: 3)); // 3초간 페이지 로딩을 시뮬레이션
    setState(() {
      _isPageLoading = false; // 로딩 완료 후 상태 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      appBar: AppBar(
        title: Text('모델'),
        centerTitle: true, // 제목을 가운데로 설정
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
      ),
      body: SafeArea(
        child: _isPageLoading
            ? Center(child: CircularProgressIndicator()) // 페이지 로딩 중일 때 전체 로딩 인디케이터 표시
            : Stack(
          children: [
            // 모델 이미지
            Positioned(
              right: 40.0,
              bottom: 90.0,
              child: Stack(
                children: [
                  Image.asset(
                    _modelImagePath, // 모델 이미지 경로
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.65,
                  ),
                  if (_isModelLoading)
                    Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(), // 모델 이미지 로딩 중일 때 인디케이터 표시
                      ),
                    ),
                ],
              ),
            ),
            // 하트 버튼
            Positioned(
              top: 90.0,
              right: 45.0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isItemsVisible = !_isItemsVisible;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF9C63D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            // 상품 목록
            if (_isItemsVisible)
              Positioned(
                top: 160.0,
                right: 45.0,
                child: Column(
                  children: _buildItemsList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemsList() {
    // 하트 버튼 아래에 표시될 상품 아이템들
    List<String> itemPaths = [
      'assets/images/item1.png',
      'assets/images/item4.png',
      'assets/images/item5.png',
    ];

    return itemPaths.map((itemPath) => _buildItem(itemPath)).toList();
  }

  Widget _buildItem(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          if (assetPath == 'assets/images/item1.png') {
            _changeModelImage('assets/images/model1.png'); // item1.png 클릭 시 model1.png로 변경
          } else if (assetPath == 'assets/images/item5.png') {
            _changeModelImage('assets/images/model2.png'); // item5.png 클릭 시 model2.png로 변경
          }
        },
        child: ClipOval(
          child: Image.asset(
            assetPath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> _changeModelImage(String newImagePath) async {
    setState(() {
      _isModelLoading = true; // 모델 이미지 로딩 시작
    });

    await Future.delayed(Duration(seconds: 2)); // 2초간 로딩을 시뮬레이션

    setState(() {
      _modelImagePath = newImagePath; // 새로운 모델 이미지로 변경
      _isModelLoading = false; // 로딩 완료
    });
  }
}
