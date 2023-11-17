import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/profile/profile_state.dart';
import 'package:sns_clonecode/repositories/feed_repository.dart';
import 'package:sns_clonecode/repositories/profile_repository.dart';

class ProfileProvider extends StateNotifier<ProfileState> with LocatorMixin {
  ProfileProvider() : super(ProfileState.init());
  //profilestate 도 동시에 객체 생성

  Future<void> getProfile({
    required String uid,
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.fetching);

    try {
      UserModel userModel =
          await read<ProfileRepository>().getProfile(uid: uid);
      List<FeedModel> feedList =
          await read<FeedRepository>().getFeedList(uid: uid);

      state = state.copyWith(
        profileStatus: ProfileStatus.success,
        feedList: feedList,
        userModel: userModel,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
    }
  }
}
