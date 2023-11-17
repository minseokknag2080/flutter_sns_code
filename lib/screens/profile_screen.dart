import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/auth/auth_provider.dart';
import 'package:sns_clonecode/providers/profile/profile_provider.dart';
import 'package:sns_clonecode/providers/profile/profile_state.dart';
import 'package:sns_clonecode/screens/profile_feed_screen.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';
import 'package:sns_clonecode/widgets/feed_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileProvider profileProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    _getProfile();
  }

  void _getProfile() {
    String uid = context.read<User>().uid;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await profileProvider.getProfile(uid: uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  Widget _profileInfoWidget({
    required int num,
    required String label,
  }) {
    return Column(children: [
      Text(
        num.toString(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = context.watch<ProfileState>();

    UserModel userModel = profileState.userModel;
    List<FeedModel> feedList = profileState.feedList;

//as imageprovider은 dart의 오류
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(
            children: [
              Column(children: [
                CircleAvatar(
                  backgroundImage: userModel.profileImage == null
                      ? ExtendedAssetImageProvider('assets/images/profile.png')
                          as ImageProvider
                      : ExtendedNetworkImageProvider(userModel.profileImage!),
                  radius: 40,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(userModel.name),
              ]),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileInfoWidget(
                        num: userModel.feedCount, label: 'feeds'),
                    _profileInfoWidget(
                        num: userModel.followers.length, label: 'follower'),
                    _profileInfoWidget(
                        num: userModel.following.length, label: 'following'),
                  ],
                ),
              )
            ],
          ),
          TextButton(
            onPressed: () async {
              await context.read<Auth_Provider>().signOut();
            },
            child: Text('Sign Out'),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
          Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: feedList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileFeedScreen(
                                    feedModel: feedList[index],
                                  )),
                        );
                      },
                      child: ExtendedImage.network(
                        feedList[index].imageUrls[0],
                        fit: BoxFit.cover,
                      ),
                    );
                  }))
        ]),
      ),
    );
  }
}
