import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mango/firebase_options.dart';
import 'package:mango/models/model_auth.dart';
import 'package:mango/models/model_provider.dart'; // WardrobeProvider와 ProductProvider를 포함하는 파일
import 'package:mango/screens/screen_chat.dart';
import 'package:mango/screens/screen_detail.dart';
import 'package:mango/screens/screen_heartlist.dart';
import 'package:mango/screens/screen_modelCreate.dart';
import 'package:mango/screens/screen_register.dart';
import 'package:mango/screens/screen_search.dart';
import 'package:provider/provider.dart';
import 'chat/model/model_chat.dart';
import 'chat/model/model_user.dart';  // UserModel을 포함한 파일
import 'chat/providers/chat_provider.dart';
import 'chat/providers/chat_repository.dart';
import 'models/model_heart.dart';
import 'models/model_query.dart';
import 'models/model_register.dart';
import 'screens/screen_splash.dart';
import 'screens/screen_index.dart';
import 'screens/screen_login.dart';
import 'tabs/tab_post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  User? firebaseUser = auth.currentUser;
  UserModel? currentUserModel;
  ChatNotifier? chatNotifier;

  if (firebaseUser != null) {
    final userDoc = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('info')
        .doc('userInfo')
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      currentUserModel = UserModel.fromMap(userDoc.data()!);

      final chatRepository = ChatRepository(
        firestore: firestore,
        auth: auth,
        storage: storage,
        documentId: 'dZpl5OOsMAa3lgLSIimw',
      );

      chatNotifier = ChatNotifier(
        chatRepository: chatRepository,
        currentUserModel: currentUserModel,
      );
    } else {
      firebaseUser = null; // 사용자 데이터가 없을 경우 재로그인 요구
    }
  }

  runApp(MyApp(
    auth: auth,
    firestore: firestore,
    chatNotifier: chatNotifier ?? ChatNotifier(
      chatRepository: ChatRepository(
        firestore: firestore,
        auth: auth,
        storage: storage,
        documentId: '', // 기본값으로 빈 문자열을 설정
      ),
      currentUserModel: currentUserModel ?? UserModel.init(), // UserModel.init()으로 기본값 설정
    ),
    initialRoute: firebaseUser == null ? '/login' : '/splash',
  ));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ChatNotifier chatNotifier;
  final String initialRoute;

  MyApp({
    required this.auth,
    required this.firestore,
    required this.initialRoute,
    required this.chatNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider(auth: auth)),
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => QueryProvider()),
        ChangeNotifierProvider(create: (_) => RegisterModel()),
        ChangeNotifierProvider(create: (_) => HeartProvider()),
        ChangeNotifierProvider(create: (_) => chatNotifier), // 항상 chatNotifier를 제공
      ],
      child: MaterialApp(
        title: 'Mango',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Pretendard',
          primaryColor: Color(0xfff9c63d),
        ),
        routes: {
          '/index': (context) => IndexScreen(),
          '/login': (context) => LoginScreen(),
          '/splash': (context) => SplashScreen(),
          '/register': (context) => RegisterScreen(),
          '/addItem': (context) => TabPost(),
          '/detail': (context) => DetailScreen(),
          '/search': (context) => SearchScreen(),
          '/screen_modelCreate': (context) => ModelCreateScreen(),
          '/heartList': (context) => ScreenHeartList(),
        },
        initialRoute: initialRoute,
        onGenerateRoute: (settings) {
          if (settings.name == ChatScreen.routeName) {
            final chatModel = settings.arguments as Chatmodel;
            return MaterialPageRoute(
              builder: (context) {
                return ChatScreen(chatModel: chatModel);
              },
            );
          }
          return null;
        },
      ),
    );
  }
}
