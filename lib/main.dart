//import 'dart:js_interop';
import 'package:firebase_auth_platform_interface/src/auth_provider.dart'
    hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/firebase_options.dart';

import 'package:sns_clonecode/providers/auth/auth_provider.dart';

import 'package:sns_clonecode/providers/auth/auth_state.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/providers/feed/feed_provider.dart';
import 'package:sns_clonecode/repositories/auth_repository.dart';
import 'package:sns_clonecode/repositories/feed_repository.dart';
import 'package:sns_clonecode/screens/signin_screen.dart';
import 'package:sns_clonecode/screens/splash_screen.dart';
//import 'package:sns_clonecode/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //signout
    //FirebaseAuth.instance.signOut();
    return MultiProvider(
      providers: [
        //provider에 등록할 데이터를 나열하면 된다.
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
              firebaseAuth: FirebaseAuth.instance,
              firebaseFirestore: FirebaseFirestore.instance,
              firebaseStorage: FirebaseStorage.instance),
        ),

        Provider<FeedRepository>(
          create: (context) => FeedRepository(
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
          ),
        ),

        //firebase에서 오류가 발생해 연결이 끊겨도 여기선 알 수 없다.
        //그러므로 실시간으로 연결상태를 확인해서
        //AuthStatus.unauthenticated 판단할 수 있는 로직
        StreamProvider<User?>(
            create: (context) => FirebaseAuth.instance.authStateChanges(),
            //firebase 로그인한 user의 데이터를 반환
            //? nullable 이기 때문에 로그인한 유저가 없으면 null
            initialData: null),
        //데이터를 가져오는데 시간이 걸리는데, 처음에는 무조건 null 이므로

//auth_provider가 StreamProvider의 user와 AuthRepository를 사용하기 때문에 미리 준비를 해줘야 한다.

        StateNotifierProvider<Auth_Provider, AuthState>(
          create: (context) => Auth_Provider(),
        ),
        StateNotifierProvider<FeedProvider, FeedState>(
          create: (context) => FeedProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}
