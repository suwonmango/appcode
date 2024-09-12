import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/model_provider.dart'; // 기존의 Product 모델이 정의된 파일을 임포트

class HeartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _heartItems = [];
  bool _isLoading = false;

  List<Product> get heartItems => _heartItems;
  bool get isLoading => _isLoading;

  // 사용자의 찜한 아이템 목록을 가져오거나 생성
  Future<void> fetchHeartItemsOrCreate(String uid) async {
    if (uid.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final heartSnapshot = await _firestore.collection('hearts').doc(uid).get();
      if (heartSnapshot.exists) {
        List<dynamic> heartItemsMap = heartSnapshot.data()?['items'] ?? [];
        _heartItems = heartItemsMap.map((item) {
          return Product.fromFirestore(item as DocumentSnapshot);
        }).toList();
      } else {
        await _firestore.collection('hearts').doc(uid).set({'items': []});
      }
    } catch (e) {
      print('Error fetching heart items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 찜 목록에 아이템 추가
  Future<void> addHeartItem(String uid, Product item) async {
    _heartItems.add(item);
    await _firestore.collection('hearts').doc(uid).update({
      'items': FieldValue.arrayUnion([item.toFirestore()]),
    });
    notifyListeners();
  }

  // 찜 목록에서 아이템 제거
  Future<void> removeHeartItem(String uid, Product item) async {
    _heartItems.removeWhere((element) => element.title == item.title);
    await _firestore.collection('hearts').doc(uid).update({
      'items': FieldValue.arrayRemove([item.toFirestore()]),
    });
    notifyListeners();
  }

  // 찜한 아이템인지 확인
  bool isHeartItem(Product item) {
    return _heartItems.any((element) => element.title == item.title);
  }
}
