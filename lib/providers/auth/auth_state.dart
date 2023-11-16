enum AuthStatus {
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus authStatus;

  const AuthState({
    required this.authStatus,
  });

  factory AuthState.init() {
    //AuthState 객체 생성할 때 factory 생성자를 이용한다.
    return AuthState(
      authStatus: AuthStatus.unauthenticated,
    );
  }

  AuthState copyWith({
    //provider에 저장되어 있는 authStatus 값 변경할 때 사용.
    //예를 들어 로그아웃에서 로그인 하면, unauthenticated 상태의 authStatus를 authenticated 상태로 바꿔준다.
    AuthStatus? authStatus, //인자
  }) {
    return AuthState(
      authStatus: authStatus ??
          this.authStatus, //authStatus 가 nulldlaus this.authStatus 리턴
      //기존의 authStatusrk null이 아니면 기존 authStatus 리턴
    );
  }
}
