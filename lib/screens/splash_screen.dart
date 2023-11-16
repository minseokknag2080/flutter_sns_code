import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/providers/auth/auth_state.dart';
import 'package:sns_clonecode/screens/main_screen.dart';
import 'package:sns_clonecode/screens/signin_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthState>().authStatus;

    //build 함수에서 위젯들이 완성되기 전에 화면 전환을 하면 순간 에러 화면이 뜬다.

    //splashscreen이 밑에 깔린 채로 그 위에 signinscreen이 보여지는 것
    //watch를 사용해서 watch<AuthState>().authStatus 계속 감시 중
    //signinscreen에서 로그인 성공하면, -> watch가 바로 확인
    //main 페이지로 이동
    //splashscreen 계속 밑에 살아 있으면서, 만약 AuthStatus.unauthenticated가 되면 바로
    //signinscreen로 보낸다.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //메인 페이지로 이동

      //메인 페이지로 이동하기 전에 그전 모든 위젯 삭제 후 이동(페이지)
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => authStatus == AuthStatus.authenticated
                ? MainScreen()
                : SigninScreen(),
          ),
          //가장 첫 번째 페이지는 남겨둔 채로 삭제
          //-> splash page만 남기고 삭제
          (route) => route.isFirst);
    });

    return Scaffold(
      body: Center(
        child:
            //로딩바
            CircularProgressIndicator(),
      ),
    );
  }
}
