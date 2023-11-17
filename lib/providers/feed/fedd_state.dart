// ignore_for_file: public_member_api_docs, sort_constructors_first
//열거형
import 'package:sns_clonecode/models/feed_model.dart';

enum FeedStatus {
  init,
  //feedstate 최초로 객체생성한 상태
  submitting,
  //게시글을 등록 중인 상태
  fetching,
  //목록을 가져오고 있는 상태
  success,
  //작업 성공
  error,
  //작업 실패
}

//게시글 상태 관리하기 위한 데이터 저장
class FeedState {
  final FeedStatus feedStatus;
  final List<FeedModel> feedList;

  const FeedState({required this.feedStatus, required this.feedList});

  factory FeedState.init() {
    return FeedState(
      feedStatus: FeedStatus.init,
      feedList: [],
    );
  }

  FeedState copyWith({
    FeedStatus? feedStatus,
    List<FeedModel>? feedList,
  }) {
    return FeedState(
      feedStatus: feedStatus ?? this.feedStatus,
      feedList: feedList ?? this.feedList,
    );
  }
}
