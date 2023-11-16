import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/providers/auth/auth_state.dart';
import 'package:sns_clonecode/repositories/auth_repository.dart';

class Auth_Provider extends StateNotifier<AuthState> with LocatorMixin
//인증 상태 변경 로직  //AuthState 으로 할 것이기 때문에 제네릭으로 전달.ㅁ
{
  Auth_Provider() : super(AuthState.init());
//생성자  //AuthProvider 생성해 주면서, AuthState 생성  //AuthState가 AuthProvider에 자동 등록 //AuthProvider만 등록하면 자동으로 같이 등록

  @override
  void update(Locator watch) {
    //locatorMixin에 정의되어 있는 함수
    //
    final user = watch<User?>();

    if (user != null && !user.emailVerified) {
      return;
    }

    if (user == null && state.authStatus == AuthStatus.unauthenticated) {
      return;
    }

    if (user != null) {
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
      );
    } else {
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
      );
    }
  }

//회원가입
  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    required Uint8List? profileImage,
  }) async {
    try {
      await read<AuthRepository>().signUp(
          email: email,
          name: name,
          password: password,
          profileImage: profileImage);
    } on CustomException catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    //authrepository에서 signout 함수 호출
    await read<AuthRepository>().signOut();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      //read 메서드는 provider에서 제공하는 상태를 읽어오는 역할을 합니다.
      await read<AuthRepository>().signIn(email: email, password: password);
    } on CustomException catch (_) {
      rethrow;
    }
  }
}
