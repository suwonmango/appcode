class UserModel {
  final String name;
  final String uid;
  final String? profileImage;

  // 생성자
  const UserModel({
    required this.name,
    required this.uid,
    this.profileImage,
  });

  // 기본값을 가지는 초기화 팩토리 생성자
  factory UserModel.init() {
    return const UserModel(
      name: '',
      uid: '',
      profileImage: null,
    );
  }

  // 객체를 맵으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profileImage': profileImage,
    };
  }

  // 맵을 객체로 변환하는 팩토리 생성자
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Check for uid and provide meaningful logging
    if (map['uid'] == null || (map['uid'] as String).isEmpty) {
      // Log the error
      print('Error: User ID is missing or empty in the map data.');
      // Handle the issue by either throwing an exception or returning a default value
      return UserModel.init(); // Returns a default user object with empty fields
    }

    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '', // uid가 null이거나 비어있을 경우를 대비한 방어코드
      profileImage: map['profileImage'], // profileImage는 null이 될 수 있음
    );
  }

  // 객체를 문자열로 변환하는 메서드 (디버깅 용도)
  @override
  String toString() {
    return 'UserModel{name: $name, uid: $uid, profileImage: $profileImage}';
  }
}
