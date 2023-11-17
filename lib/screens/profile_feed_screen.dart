import 'package:flutter/material.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/widgets/feed_card_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final FeedModel feedModel;
  const ProfileFeedScreen({super.key, required this.feedModel});

  @override
  State<ProfileFeedScreen> createState() => ProfileFeedScreenState();
}

class ProfileFeedScreenState extends State<ProfileFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FeedCardWidget(
        feedModel: widget.feedModel,
      )),
    );
  }
}
