import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/avatar_widget.dart';

class FeedCardWidget extends StatefulWidget {
  final FeedModel feedModel;

  const FeedCardWidget({super.key, required this.feedModel});

  @override
  State<FeedCardWidget> createState() => _FeedCardWidgetState();
}

class _FeedCardWidgetState extends State<FeedCardWidget> {
  final CarouselController carouselController = CarouselController();
  int _indicatorIndex = 0;

  Widget _imageZoomInOutWidget(String imageUrls) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return InteractiveViewer(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: ExtendedImage.network(imageUrls),
              ),
            );
          },
        );
      },
      child: ExtendedImage.network(
        imageUrls,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _imageSliderWidget(List<String> imageUrls) {
    return Stack(children: [
      CarouselSlider(
        carouselController: carouselController,
        items: imageUrls.map((url) => _imageZoomInOutWidget(url)).toList(),
        options: CarouselOptions(
          onPageChanged: (index, reason) {
            //현재 표시되고 있는 사진의 index값
            setState(() {
              _indicatorIndex = index;
            });
          },
          viewportFraction: 1.0,
          height: MediaQuery.of(context).size.height * 0.35,
        ),
      ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //tolist함수 반환 자체가 리스트가 반환 된 것이므로.
            children: imageUrls.asMap().keys.map((e) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withOpacity(_indicatorIndex == e ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    FeedModel feedModel = widget.feedModel;
    UserModel userModel = feedModel.writer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              AvatarWidget(userModel: userModel),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  userModel.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              )
            ],
          ),
        ),
        _imageSliderWidget(feedModel.imageUrls),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                feedModel.likeCount.toString(),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.comment_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                feedModel.commentCount.toString(),
                style: TextStyle(fontSize: 16),
              ),

              //차지할 수 있는 가장 많은 공간 차지
              Spacer(),

              //분리가 될 기준을 정해주고 분리 후 list<string>이 반환되기 때문에 0번째 index만 가져와서 사용
              Text(
                feedModel.createAt.toDate().toString().split(' ')[0],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            feedModel.desc,
            style: TextStyle(fontSize: 16),
          ),
        )
      ]),
    );
    ;
  }
}
