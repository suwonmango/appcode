// screens/screen_register.dart
// 사용자가 이메일과 비밀번호를 입력하고 회원가입 할 수 있는 기능 제공
// 위젯 트리 전체에 걸쳐 상태를 공유하고 관리하기 유용하도록 Provider사용
// registButton에서는 실제로 authClient를 이용해 파이어 베이스에 저장하는 함수를 실행
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mango/models/model_auth.dart';
import 'package:mango/models/model_register.dart';

// RegisterScreen 클래스 - 회원가입 화면을 나타내는 StatelessWidget 인데 혜린이가 stf로 바꿔버림
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final regionController = TextEditingController();
  File? image;

  @override
  void dispose() {
    nameController.dispose();
    regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '회원가입',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0C141C),
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 0.05,
            letterSpacing: -0.27,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _profileWidget(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 12, bottom: 8),
              child: NameInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8, bottom: 6),
              child: EmailInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 6, bottom: 6),
              child: PasswordInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 6, bottom: 8),
              child: PasswordConfirmInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8, bottom: 6),
              child: RegionInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 6.0, bottom: 0),
              child: RegisterButton(),
            ),
          ],
        ),
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
      // listen: false로 설정하여 이벤트 핸들러에서 안전하게 사용
      final register = Provider.of<RegisterModel>(context, listen: false);

      final imageFile = File(pickedImage.path);

      // Debugging: 이미지 경로 확인
      print('Selected image path: ${imageFile.path}');

      // 이미지 설정
      register.setImage(imageFile);

      print('Image in register after setting: ${register.image}');

      setState(() {
        image = imageFile;
      });
    } else {
      print('No image selected.');
    }
  }






  Widget _profileWidget() {
    final register = Provider.of<RegisterModel>(context);

    return register.image == null
        ? GestureDetector(
      onTap: _selectImage,
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
            backgroundImage: FileImage(register.image!),
            radius: 60,
          ),
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
              )),
        ],
      ),
    );
  }


}

// EmailInput 클래스 - 이메일 입력 필드
class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return TextField(
      onChanged: (email) {
        register.setEmail(email); // 이메일 입력 시 모델에 값 설정
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8EDF2), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4F7296), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: '이메일',
        labelStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        hintText: '이메일를 입력하세요!',
        hintStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        filled: true,
        fillColor: Color(0xFFE8EDF2),
      ),
    );
  }
}

// PasswordInput 클래스 - 비밀번호 입력 필드
class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return TextField(
      onChanged: (password) {
        register.setPassword(password); // 비밀번호 입력 시 모델에 값 설정
      },
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8EDF2), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4F7296), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: '비밀번호',
        labelStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        hintText: '비밀번호를 입력하세요!',
        hintStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        filled: true,
        fillColor: Color(0xFFE8EDF2),
        errorText: register.password != register.passwordConfirm
            ? '비밀번호가 일치하지 않습니다.'
            : null, // 비밀번호 불일치 시 오류 메시지 표시
      ),
    );
  }
}

// PasswordConfirmInput 클래스 - 비밀번호 확인 입력 필드
class PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return TextField(
      onChanged: (password) {
        register.setPasswordConfirm(password); // 비밀번호 확인 입력 시 모델에 값 설정
      },
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8EDF2), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4F7296), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: '비밀번호 확인',
        labelStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        hintText: '비밀번호를 다시 입력하세요!',
        hintStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        filled: true,
        fillColor: Color(0xFFE8EDF2),
      ),
    );
  }
}

// RegisterButton 클래스 - 회원가입 버튼
class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      height: 48,
      width: 358,
      decoration: BoxDecoration(
        color: Color(0xFF4F7396),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF9C63D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: (register.password != register.passwordConfirm)
            ? null
            : () async {
          // Debugging: RegisterModel의 image가 null인지 확인
          print('Image in register: ${register.image}');

          // 이미지가 null인지 확인
          if (register.image == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('프로필 이미지를 선택해 주세요.')),
            );
            return; // 이미지가 없으면 회원가입 절차 중단
          }

          // 회원가입 시도 + 조건을 추가하고 싶다면 여기에 추가하면 됨
          await authClient
              .registerWithEmail(register.email, register.password)
              .then((registerStatus) async {
            if (registerStatus == AuthStatus.registerSuccess) {
              // Firebase Auth에 의해 생성된 사용자 UID 가져오기
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // 프로필 이미지를 Firebase Storage에 업로드
                String? profileImageUrl;
                if (register.image != null) {
                  try {
                    // Firebase Storage에 이미지 업로드
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('users/${user.uid}/profileImage');

                    // File을 위한 UploadTask 생성 및 실행
                    UploadTask uploadTask =
                    storageRef.putFile(register.image!);

                    // 업로드 완료 및 URL 가져오기
                    final snapshot = await uploadTask.whenComplete(() {});
                    profileImageUrl = await snapshot.ref.getDownloadURL();
                  } catch (e) {
                    // 이미지 업로드 실패 시 오류 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('프로필 이미지 업로드에 실패했습니다: $e')),
                    );
                    return; // 오류 발생 시 아래 코드 실행 방지
                  }
                }

                // 현재 연도 가져오기
                final currentYear = DateTime.now().year.toString();

                // Firestore에 사용자 정보 저장
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('info')
                    .doc('userInfo') // 문서 이름을 'userInfo'로 지정
                    .set({
                  'uid': user.uid,  // **[수정된 부분]** uid를 함께 저장
                  'name': register.name,
                  'region': register.region,
                  'profileImage': profileImageUrl,
                  'joinYear': currentYear, // 가입 연도 추가
                });

                // 회원가입 성공 시 메시지 표시
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('회원가입 성공!')),
                  );
                Navigator.pop(context); // 회원가입 화면 닫기
              } else {
                // 회원가입 실패 시 메시지 표시
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('회원가입 실패')),
                  );
              }
            }
          });
        },
        child: Text(
          '회원가입',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFF7F9FC),
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 0.09,
            letterSpacing: 0.24,
          ),
        ),
      ),
    );
  }
}

//이름(닉네임) 입력
class NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return TextField(
      onChanged: (name) {
        register.setName(name); // 이름 입력 시 모델에 값 설정
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8EDF2), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4F7296), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: '이름(닉네임)',
        labelStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        hintText: '이름(닉네임)을 입력하세요!',
        hintStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        filled: true,
        fillColor: Color(0xFFE8EDF2),
      ),
    );
  }
}

//내 지역 입력
class RegionInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return TextField(
      onChanged: (region) {
        register.setRegion(region); // 지역 입력 시 모델에 값 설정
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8EDF2), width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4F7296), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelText: '내 지역',
        labelStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        hintText: '지역을 입력하세요!',
        hintStyle: TextStyle(
          color: Color(0xFF4F7296),
          fontSize: 16,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 0.09,
        ),
        filled: true,
        fillColor: Color(0xFFE8EDF2),
      ),
    );
  }
}
