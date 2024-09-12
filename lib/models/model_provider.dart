import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// WardrobeItem 클래스 - 옷장 아이템을 나타내는 데이터 모델 클래스
class WardrobeItem {
  final String imageUrl; // 옷장 아이템의 이미지 URL
  final DateTime timestamp; // 아이템이 추가된 시간

  WardrobeItem({required this.imageUrl, required this.timestamp});

  // Firestore의 DocumentSnapshot을 WardrobeItem 객체로 변환하는 팩토리 생성자
  factory WardrobeItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map; // 문서 데이터를 Map으로 변환
    return WardrobeItem(
      imageUrl: data['imageUrl'] ?? '', // 이미지 URL
      timestamp: (data['timestamp'] as Timestamp).toDate(), // 타임스탬프
    );
  }

  // WardrobeItem 객체를 Firestore에 저장할 수 있는 Map으로 변환하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl, // 이미지 URL
      'timestamp': Timestamp.fromDate(timestamp), // 타임스탬프
    };
  }
}

// WardrobeProvider 클래스 - 옷장 아이템을 관리하고 UI에 알리는 클래스
class WardrobeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  List<WardrobeItem> _items = []; // 옷장 아이템 리스트
  bool _isLoading = false; // 로딩 상태

  List<WardrobeItem> get items => _items; // 옷장 아이템 리스트 Getter
  bool get isLoading => _isLoading; // 로딩 상태 Getter

  // Firestore에서 옷장 아이템을 가져오는 비동기 메서드
  Future<void> fetchWardrobeItems() async {
    if (_items.isNotEmpty) return; // 이미 아이템이 있으면 반환

    _isLoading = true; // 로딩 시작
    notifyListeners(); // UI 업데이트

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('wardrobe').get(); // Firestore에서 옷장 아이템 가져오기
      _items = querySnapshot.docs
          .map((doc) => WardrobeItem.fromFirestore(doc))
          .toList(); // 문서들을 WardrobeItem 리스트로 변환
    } catch (e) {
      print('Error fetching wardrobe items: $e');
      _items = []; // 에러 발생 시 빈 리스트로 초기화
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners(); // UI 업데이트
    }
  }

  // Firestore에 새로운 옷장 아이템을 추가하는 비동기 메서드
  Future<void> addWardrobeItem(WardrobeItem item) async {
    try {
      await _firestore.collection('wardrobe').add(item.toFirestore()); // Firestore에 아이템 추가
      await fetchWardrobeItems(); // 리스트 갱신
    } catch (e) {
      print('Error adding wardrobe item: $e');
    }
  }
}

class Product {
  final String title; // 제품 제목
  final String description; // 제품 설명
  final double price; // 제품 가격
  final String category; // 제품 카테고리
  final List<String> images; // 제품 이미지 리스트
  final String size; // 제품 사이즈
  final String gender; // 제품 성별
  final DateTime timestamp; // 제품 추가 시간
  final String userId; // 사용자 ID (추가된 필드)

  Product({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.size,
    required this.gender,
    required this.timestamp,
    required this.userId, // 생성자에 추가
  });

  // Firestore의 DocumentSnapshot을 Product 객체로 변환하는 팩토리 생성자
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map; // 문서 데이터를 Map으로 변환
    return Product(
      title: data['title'] ?? '', // 제품 제목
      description: data['description'] ?? '', // 제품 설명
      price: (data['price'] ?? 0.0).toDouble(), // 제품 가격 (null 체크 및 double 형변환)
      category: data['category'] ?? '', // 제품 카테고리
      images: List<String>.from(data['images'] ?? []), // 제품 이미지 리스트
      size: data['size'] ?? '', // 제품 사이즈
      gender: data['gender'] ?? '', // 제품 성별
      timestamp: (data['timestamp'] as Timestamp).toDate(), // 타임스탬프
      userId: data['userId'] ?? '', // 사용자 ID
    );
  }

  // Product 객체를 Firestore에 저장할 수 있는 Map으로 변환하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'title': title, // 제품 제목
      'description': description, // 제품 설명
      'price': price, // 제품 가격
      'category': category, // 제품 카테고리
      'images': images, // 제품 이미지 리스트
      'size': size, // 제품 사이즈
      'gender': gender, // 제품 성별
      'timestamp': Timestamp.fromDate(timestamp), // 타임스탬프
      'userId': userId, // 사용자 ID
    };
  }

  // copyWith 메서드 추가
  Product copyWith({
    String? title,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    String? size,
    String? gender,
    DateTime? timestamp,
    String? userId,
  }) {
    return Product(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      size: size ?? this.size,
      gender: gender ?? this.gender,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}


// ProductProvider 클래스 - 제품을 관리하고 UI에 알리는 클래스
class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  List<Product> _products = []; // 제품 리스트
  List<Product> _searchResults = []; // 검색 결과 리스트
  bool _isLoading = false; // 로딩 상태

  List<Product> get products => _products; // 제품 리스트 Getter
  List<Product> get searchResults => _searchResults; // 검색 결과 Getter
  bool get isLoading => _isLoading; // 로딩 상태 Getter

  // Firestore에서 제품을 가져오는 비동기 메서드
  Future<void> fetchProducts() async {
    _isLoading = true; // 로딩 시작
    notifyListeners(); // UI 업데이트
    print('Fetching products...');

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('product').get(); // Firestore에서 모든 제품 가져오기
      _products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList(); // 문서들을 Product 리스트로 변환
      print('Fetched ${_products.length} products.');
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners(); // UI 업데이트
    }
  }


  // Firestore에서 특정 쿼리로 제품을 검색하는 비동기 메서드
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchResults = _products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    notifyListeners();
  }

  // Firestore에 새로운 제품을 추가하는 비동기 메서드
  Future<void> addProduct(Product product) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // 현재 로그인한 사용자 ID
      if (userId == null) {
        print('User is not logged in');
        return; // 로그인하지 않은 경우 반환
      }

      final productWithUser = product.copyWith(userId: userId); // 사용자 ID를 포함한 제품 객체 생성

      await _firestore.collection('product').add(productWithUser.toFirestore()); // Firestore에 제품 추가
      await fetchProducts(); // 리스트 갱신
      notifyListeners(); // UI 갱신 알림
    } catch (e) {
      print('Error adding product: $e');
    }
  }

}
