//screen_edit 프로필 편집

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mango/screens/screen_login.dart';
import 'package:provider/provider.dart';

import '../models/model_auth.dart';

class editScreen extends StatefulWidget {
  const editScreen({super.key});

  @override
  State<editScreen> createState() => _editScreenState();
}

class _editScreenState extends State<editScreen> {
  final nameController = TextEditingController();
  final regionController = TextEditingController();
  File? image;

  @override
  void dispose() {
    nameController.dispose();
    regionController.dispose();
    super.dispose();
  }

//사진추가 아이콘
  Widget _profileWidget() {
    return image == null
        ? GestureDetector(
      //아이콘을 눌렀을 때 갤러리에서 선택할 수 있게 함 gesturedetector-onTap
      onTap: () async {
        await _selectImage();
      },
      child: CircleAvatar(
        backgroundColor: Colors.grey.withOpacity(0.7),
        radius: 60,
        child: const Icon(
          Icons.add_a_photo,
          color: Colors.black,
          size: 30,
        ),
      ),
    )
        : GestureDetector(
      onTap: _selectImage,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: FileImage(image!),
            radius: 60,
          ),
          //사진 변경 아이콘
          Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  backgroundColor: Color(0xFFF9C63D),
                  radius: 15,
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

//갤러리에서 사진 가져오기
  Future<void> _selectImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  // Firebase에 사진과 정보를 저장하는 함수
  Future<void> _saveProfile() async {
    //필요없을 듯
    // if (nameController.text.isEmpty || regionController.text.isEmpty || image == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('모든 칸을 채워주세요!')),
    //   );
    //   return;
    // }

    try {
      // Firebase Storage에 이미지 수정
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef =
      FirebaseStorage.instance.ref().child('profiles/$fileName');
      await storageRef.putFile(image!);
      String imageUrl = await storageRef.getDownloadURL();

      // Firestore에 데이터 수정
      final userId =
          Provider.of<FirebaseAuthProvider>(context, listen: false).user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': nameController.text,
        'region': regionController.text,
        'profileImageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필이 성공적으로 수정되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 수정 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isChecked = true; //스위치땜에 필요한 변수

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      resizeToAvoidBottomInset: false, // 키보드에 맞춰 화면을 조정

      body: Stack(
        children: [
          Column(
            children: [
              const Divider(
                color: Color.fromARGB(76, 153, 163, 175), //선 색상
                thickness: 1, //선 두께
              ),

              //프사
              const SizedBox(height: 24),
              _profileWidget(),
              const SizedBox(height: 20),

              //닉네임, 내지역(, 알림설정)
              Expanded(
                child: Column(
                  children: [
                    // 닉네임 입력
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(29, 10, 20, 0),
                            child: Text(
                              '닉네임',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFF9C63D),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '닉네임을 입력하세요.',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12.0), // 좌우 여백
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '닉네임을 입력하세요.';
                                  }
                                  return null;
                                },
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 지역 선택
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(29, 0, 20, 0),
                            child: Text(
                              '내 지역',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFF9C63D),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '지역을 입력하세요.',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12.0), // 좌우 여백
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //알림설정
                    Padding(
                      padding: const EdgeInsets.fromLTRB(29, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //텍스트랑 버튼 사이 공간
                        children: [
                          const Text(
                            '알림설정',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          CupertinoSwitch(
                            value: _isChecked,
                            activeColor: Color(0xFFF9C63D),
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              LoginOutButton(),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _saveProfile,
                child: OkButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//로그아웃
class LoginOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              await authClient.logout();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Logout successful!')));
              // 모든 이전 화면을 제거하고 로그인 화면으로 이동
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFF9C63D),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//수정버튼
Widget OkButton() {
  return Container(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFF9C63D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '확인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
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
