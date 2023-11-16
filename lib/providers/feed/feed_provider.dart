import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/repositories/feed_repository.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  FeedProvider() : super(FeedState.init());

  Future<void> uploadFeedd({
    required List<String> files,
    required String desc,
  }) async {
    String uid = read<User>().uid;
    await read<FeedRepository>().uploadFeed(
      files: files,
      desc: desc,
      uid: uid,
    );
  }
}
