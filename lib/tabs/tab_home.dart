import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mango/models/model_provider.dart';
import '../models/model_heart.dart';
import '../screens/screen_detail.dart';

// TabHome 클래스 - 홈 화면을 나타내는 StatefulWidget
class TabHome extends StatefulWidget {
  @override
  _TabHomeState createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  final NumberFormat numberFormat = NumberFormat('###,###,###,###');

  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때 제품과 옷장 아이템을 불러옴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<WardrobeProvider>(context, listen: false).fetchWardrobeItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return TabBarView(
                    children: [
                      _buildMainScreen(),
                      _buildCategoryScreen('빅사이즈'),
                      _buildCategoryScreen('상의'),
                      _buildCategoryScreen('팬츠'),
                      _buildCategoryScreen('트레이닝'),
                      _buildCategoryScreen('신발'),
                      _buildCategoryScreen('기타'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  // 검색 바 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/search'); // 검색 화면으로 이동
        },
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: ShapeDecoration(
            color: Color(0xFFE8EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.search, color: Color(0xFF637587)), // 검색 아이콘 추가
              SizedBox(width: 8),
              Text(
                '원하는 상품을 검색해보세요.',
                style: TextStyle(
                  color: Color(0xFF637587),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 탭 바 위젯
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        indicatorColor: Color(0xfff9c63d),
        labelColor: Color(0xff121417),
        unselectedLabelColor: Color(0xff637587),
        labelPadding: EdgeInsets.symmetric(horizontal: 4),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold, // 선택된 탭의 글씨 굵기 설정
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal, // 선택되지 않은 탭의 글씨 굵기 설정
        ),
        tabs: [
          Tab(text: '메인'),
          Tab(text: '빅사이즈'),
          Tab(text: '상의'),
          Tab(text: '팬츠'),
          Tab(text: '신발'),
          Tab(text: '기타'),
        ],
      ),
    );
  }

  // 메인 화면 위젯
  Widget _buildMainScreen() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            _buildNewProductsSection(), // 새 상품 섹션
            _buildInterestedProductsSection(), // 관심 상품 섹션
          ],
        ),
      ),
    );
  }

  // 카테고리별 화면 위젯
  Widget _buildCategoryScreen(String category) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final categoryProducts = productProvider.products
            .where((product) => product.category == category)
            .toList();

        if (categoryProducts.isEmpty) {
          return Center(child: Text('이 카테고리에 상품이 존재하지 않습니다'));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: categoryProducts.length,
          itemBuilder: (context, index) {
            final product = categoryProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(),
                    settings: RouteSettings(
                      arguments: product,
                    ),
                  ),
                );
              },
              child: _buildProductItem(
                product.images.first,
                product.title,
                _formatPrice(product.price.toInt()), // double을 int로 변환
              ),
            );
          },
        );
      },
    );
  }

  // 새 상품 섹션 위젯
  Widget _buildNewProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final newProducts = productProvider.products.take(5).toList();

        if (newProducts.isEmpty) {
          return Center(child: Text('새상품이 없습니다'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '새 상품',
                style: TextStyle(
                  color: Color(0xFF0C141C),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.33,
                ),
              ),
              SizedBox(height: 24),
              Container(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newProducts.length,
                  itemBuilder: (context, index) {
                    final product = newProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(),
                            settings: RouteSettings(
                              arguments: product,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: _buildProductItem(
                          product.images.first,
                          product.title,
                          _formatPrice(product.price.toInt()), // double을 int로 변환
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 상품 아이템 위젯
  Widget _buildProductItem(String imagePath, String title, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: ShapeDecoration(
            color: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.error));
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF0C141C),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$price원',
          style: TextStyle(
            color: Color(0xFF4F7296),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 관심 상품 섹션 위젯
  Widget _buildInterestedProductsSection() {
    return Consumer<HeartProvider>( //하트 프로바이더 불러오기
      builder: (context, heartProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '관심 상품',
                style: TextStyle(
                  color: Color(0xFF0C141C),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.33,
                ),
              ),
              SizedBox(height: 24),
              if (heartProvider.isLoading)
                Center(child: CircularProgressIndicator())
              else if (heartProvider.heartItems.isEmpty)
                Center(
                  child: Text(
                    '관심 상품이 존재하지 않습니다.',
                    style: TextStyle(
                      color: Color(0xFF637587),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 165,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 17,
                        top: 119,
                        child: Container(
                          width: 91,
                          height: 32,
                          padding: const EdgeInsets.only(top: 5, left: 16, right: 16, bottom: 6),
                          decoration: ShapeDecoration(
                            color: Color(0xFFE8EDF2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '채팅하기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF0C141C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 220,
                        top: 13.50,
                        child: Container(
                          width: 109,
                          height: 137,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Image.network(
                            heartProvider.heartItems.last.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Icon(Icons.error));
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 81.50,
                        child: Text(
                          '사이즈: ${heartProvider.heartItems.last.size}',
                          style: TextStyle(
                            color: Color(0xFF4F7296),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 37.50,
                        child: Text(
                          heartProvider.heartItems.last.title,
                          style: TextStyle(
                            color: Color(0xFF0C141C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 58,
                        child: Text(
                          '${_formatPrice(heartProvider.heartItems.last.price.toInt())}원', // double을 int로 변환
                          style: TextStyle(
                            color: Color(0xFF0C141C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 12.50,
                        child: Text(
                          heartProvider.heartItems.last.category,
                          style: TextStyle(
                            color: Color(0xFF4F7296),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }


  // 가격을 형식화하는 메서드
  String _formatPrice(int price) {
    return numberFormat.format(price);
  }
}
