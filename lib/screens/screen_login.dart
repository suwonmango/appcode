// screens/screen_login.dart
// ChangeNotifierProvider를 사용하여 LoginModel을 추가하고, 각각의 Input 위젯 안에서 Provider를 사용해 입력값을 받아 처리하는 구조
// 로그인 버튼을 누르면 authClient의 loginWithEmail을 호출하여 Firebase에 저장된 회원 정보를 이용해 로그인을 처리
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mango/models/model_auth.dart';
import 'package:mango/models/model_login.dart';

// 로그인 화면을 나타내는 StatelessWidget
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginModel(), // LoginModel을 Provider로 추가하여 상태 관리
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'AI 중고거래앱 망고',
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
            children: <Widget>[
              // 로고 이미지
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                child: Center(
                  child: Container(
                      width: 200,
                      height: 150,
                      child: Image.asset('assets/images/망고로고.png')),
                ),
              ),
              // 이메일 입력 필드
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
                child: EmailInput(),
              ),
              // 비밀번호 입력 필드
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
                child: PasswordInput(),
              ),
              // 로그인 버튼
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 12.0),
                child: LoginButton(),
              ),
              // 회원가입 버튼
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 12.0),
                child: RegisterButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 이메일 입력 필드
class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final login = Provider.of<LoginModel>(context, listen: false); // LoginModel을 사용하여 이메일 설정
    return TextField(
      onChanged: (email) {
        login.setEmail(email); // 이메일 입력 시 모델에 값 설정
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
        hintText: '이메일을 입력하세요!',
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

// 비밀번호 입력 필드
class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final login = Provider.of<LoginModel>(context, listen: false); // LoginModel을 사용하여 비밀번호 설정
    return TextField(
      onChanged: (password) {
        login.setPassword(password); // 비밀번호 입력 시 모델에 값 설정
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
      ),
    );
  }
}

// 로그인 버튼
class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FirebaseAuthProvider를 Provider에서 가져옵니다
    final authClient = Provider.of<FirebaseAuthProvider>(context, listen: false);
    final login = Provider.of<LoginModel>(context, listen: false); // LoginModel에서 입력된 이메일과 비밀번호 가져옴

    // authClient가 제대로 초기화되었는지 확인하기 위한 디버그 로그
    assert(authClient != null, 'FirebaseAuthProvider is not found in the widget tree');
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
        onPressed: () async {
          await authClient
              .loginWithEmail(login.email, login.password) // 로그인 시도
              .then((loginStatus) {
            if (loginStatus == AuthStatus.loginSuccess) {
              // 로그인 성공 시
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content:
                    Text('환영합니다! ' + authClient.user!.email! + ' ')));
              Navigator.pushReplacementNamed(context, '/index'); // 홈 화면으로 이동
            } else {
              // 로그인 실패 시
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('로그인 실패')));
            }
          });
        },
        child: Text(
          '로그인',
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

// 회원가입 버튼
class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 358,
      decoration: BoxDecoration(
        color: Color(0xFF4F7396),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE8EDF2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/register'); // 회원가입 화면으로 이동
        },
        child: Text(
          '새로운 유저라면? 회원가입',
          style: TextStyle(
            color: Color(0xFF0C141C),
            fontSize: 13,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 0.14,
            letterSpacing: 0.24,
          ),
        ),
      ),
    );
  }
}
