class CustomException implements Exception {
  final String code; //firebase 관련 예외 코드 가지고 있다.
  final String message; //상세 정보

  const CustomException({
    required this.code,
    required this.message,
  });

  @override
  String toString() {
    return this.message;
  }
  //toString을 오버라이드 하면, customexception 객체를 print함수로 출력을 할 때 tostring 함수가 호출이 되서,
  //filed 변수를 프린트 하게 된다.
}

//잘못된 비밀번호 입력 -> wrong-password
//회원가입 중 이미 등록된 이메일로 하려고 했다. -> email-already-in-use
