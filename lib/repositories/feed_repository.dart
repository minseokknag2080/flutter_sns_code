import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:uuid/uuid.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,

//feeds 컬렉션에 저장
//피드 각각이 문서
//이미지는 storage에 직접 저장하고 firestore에 접근할 수 있는 url 문자열로 받을 것이다.
//좋아요 수
//이 게시글에 달린 댓글의 수
//게시글을 작성한 날짜
//feeds에서 user의 정보를 바로 가져올 수 있게 reference 타입의 데이터를 저장한다.
  }) async {
//파이어스토어에 데이터 저장하기위해서
//문서 아이디는 겹치지 않는 고유한 값으로 만들어야 한다.

//a-z 알파벳
//0~9 숫자
//이 두가지를 조합해서 32글자의 고유한 값을 만들어 준다.
//32글자에 - 4개씩 들어가서 36글자가 된다.
//고유한 값을 만드는 방법 여러가지 version1 ....
//우리는 version1을 사용 (현재 시간을 기준으로 random값을 만들어 준다.)

    String feedId = Uuid().v1();

    //firestore 문서 참조
    DocumentReference<Map<String, dynamic>> feedDocRef =
        firebaseFirestore.collection('feeds').doc(feedId);

    DocumentReference<Map<String, dynamic>> userDocRef =
        firebaseFirestore.collection('users').doc(uid);

    //storage 참조
    Reference ref = firebaseStorage.ref().child('feeds').child(feedId);

    List<String> imageUrls = await Future.wait(files.map((e) async {
      //문자열 e는 이미지 파일에 접근할 수 있는 경로
      String imageId = Uuid().v1();
      TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
      return await taskSnapshot.ref.getDownloadURL();
    }).toList());

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await userDocRef.get();

    UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

    FeedModel feedModel = FeedModel.fromMap({
      'uid': uid,
      'feedId': feedId,
      'desc': desc,
      'imageUrls': imageUrls,
      'likes': [],
      'likeCount': 0,
      'commentCount': 0,
      'createAt': Timestamp.now(),
      'writer': userModel,
    });

    await feedDocRef.set(feedModel.toMap(userDocRef: userDocRef));

    // await feedDocRef.set({
    //   'uid': uid,
    //   'feedId': feedId,
    //   'desc': desc,
    //   'imageUrls': imageUrls,
    //   'likes': [],
    //   'commentCount': 0,
    //   'likeCount': 0,
    //   'creatAt': Timestamp.now(),
    //   'writer': userDocRef,
    // });

    await userDocRef.update({
      'feedCount': FieldValue.increment(1),
    });
  }
}
