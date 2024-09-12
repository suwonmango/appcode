import 'package:flutter/material.dart';
import 'package:mango/screens/screen_detail.dart';
import 'package:provider/provider.dart';
import 'package:mango/models/model_provider.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (text) {
            productProvider.searchProducts(text);
          },
          autofocus: true,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            border: InputBorder.none,
          ),
          cursorColor: Colors.grey,
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white, // 전체 배경색을 흰색으로 설정
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: productProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = productProvider.searchResults[index];
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
                  product.price.toInt(), // double을 int로 변환
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductItem(String imagePath, String title, int price) {
    return Container(
      color: Colors.white, // 개별 아이템 배경색을 흰색으로 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
