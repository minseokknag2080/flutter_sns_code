import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';

enum ProfileStatus {
  init,
  //ProfileState 처음 객체 생성했을 때 상태
  submitting,
  //작업이 진행 중일 때
  fetching,
  //해당 유저의 작성 게시물을 가져오고 있는 상태
  success,
  //작업 성공
  error,
  //문제 발생
}

class ProfileState {
  final ProfileStatus profileStatus;
  final UserModel userModel;
  //유저 정보
  final List<FeedModel>
      feedList; //유저가 작성한 게시물 정보는 feedcollection //게시글 정보가 여러개이기 때문에 list로 값을 가져온다.

  ProfileState({
    required this.profileStatus,
    required this.userModel,
    required this.feedList,
  });

  factory ProfileState.init() {
    return ProfileState(
      profileStatus: ProfileStatus.init,
      userModel: UserModel.init(),
      //user_model.dart 에서 init 호출로 초기화
      feedList: [],
    );
  }

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    UserModel? userModel,
    List<FeedModel>? feedList,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      userModel: userModel ?? this.userModel,
      feedList: feedList ?? this.feedList,
    );
  }
}
