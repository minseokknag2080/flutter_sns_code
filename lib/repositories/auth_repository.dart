import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const AuthRepository({
    //생성자 매개변수로 filed 변수에 대입
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

//signout
  Future<void> signOut() async {
    //firebaseauth에서 signout 하기 위해서
    await firebaseAuth.signOut();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      //비동기로 동작하고, 로그인한 유저 정보를 갖고 있는 유저 credential 객체를 반환한다.
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //인증 이메일 눌렀으면 true 안 했으면 false
      bool isVerified = userCredential.user!.emailVerified;
      if (!isVerified) {
        //메일 재발송
        await userCredential.user!.sendEmailVerification();

        //로그아웃  왜 로그아웃 시키는 지는 모르겠음
        await firebaseAuth.signOut();

//예외 발생
        throw CustomException(code: 'Exception', message: '인증되지 않은 이메일');
      }
    } on FirebaseException catch (e) {
      throw CustomException(code: e.code, message: e.message!);
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    //profileImage는 nullable
    required Uint8List? profileImage,
  }) async {
    try {
//어떤 파이어베이스 서비스를 이용하던 간에 인스턴스를 생성하고 전달받아서 서비스 이용.
      //FirebaseAuth.instance;

      //로그인 할 때나 회원가입할 때나 쓰이기 때문에 filed 변수로

      //이걸 이용하면 자동으로 email password 전송    //future 반환 비동기로 동작 //반환 받는 데이터 UserCredential -> 로그인된 유저의 데이터가 들어 있다.
      //회원가입과 동시에 로그인 된다.
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //회원가입하면 그 유저 고유의 id 값 생성 -> profile 파일의 파일 명으로 사용하겠다.
      String uid = userCredential.user!.uid;

      //확인 메일을 받아야 가입되는 것으로 하겠다.
      //비동기이기 때문에 await를 사용해서 동기적으로 사용하겠다.
      await userCredential.user!.sendEmailVerification();
      // //false 인데 링크 클릭하면 true로 바뀐다.
      // userCredential.user.emailVerified

      String? downloadURL = null;
      //downloadURL null 이라면 기본 프로필 (사진 바꾸지 않았다.)

      if (profileImage != null) {
        Reference ref = firebaseStorage.ref().child('profile').child(uid);

        TaskSnapshot snapshot = await ref.putData(profileImage);
        // UploadTask uploadTask = ref.putData(profileImage);
        //저장 중인데 이미지 파일 url을 가져올려고 하니까 에러가 발생한다.
        downloadURL = await snapshot.ref.getDownloadURL();
      }

      await firebaseFirestore.collection('users').doc(uid).set(
          //data 형식 map
          {
            'uid': uid,
            'email': email,
            'name': name,
            'profileImage': downloadURL,
            'feedCount': 0,
            'likes': [],
            'followers': [],
            'following': [],
          });

      firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      //firebase 관련 예외

      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      //그 밖의 예외
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }

    //결국 하나의 예외로 만들어서 signup 함수를 호출하는 곳에서 쓰로우 할 것이다.
    //provider에서 signup 함수를 호출하고 있는 부분에서 예외처리를 하도록 시킨다.
  }
}
