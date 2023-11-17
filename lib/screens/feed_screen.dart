import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/providers/feed/feed_provider.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/avatar_widget.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';
import 'package:sns_clonecode/widgets/feed_card_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin<FeedScreen> {
  late final FeedProvider feedProvider;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    feedProvider = context.read<FeedProvider>();
    _getFeedList();
  }

  void _getFeedList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await feedProvider.getFeedList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    FeedState feedState = context.watch<FeedState>();
    List<FeedModel> feedList = feedState.feedList;

    if (feedState.feedStatus == FeedStatus.fetching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (feedState.feedStatus == FeedStatus.success && feedList.length == 0) {
      return Center(
        child: Text('Feed가 존재하지 않습니다.'),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _getFeedList();
        },
        child: ListView.builder(
          itemCount: feedList.length,
          itemBuilder: (context, index) {
            return FeedCardWidget(feedModel: feedList[index]);
          },
        ),
      ),
    );
  }
}
