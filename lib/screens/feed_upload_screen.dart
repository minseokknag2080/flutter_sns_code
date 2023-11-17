import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/providers/feed/feed_provider.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';

class FeedUploadScreen extends StatefulWidget {
  //인자값도 반환값도 없다.
  final VoidCallback onFeedUploaded;

  const FeedUploadScreen({super.key, required this.onFeedUploaded});

  @override
  State<FeedUploadScreen> createState() => _FeedUploadScreenState();
}

class _FeedUploadScreenState extends State<FeedUploadScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  //빈 리스트 //final 이기 때문에 변경 불가
  final List<String> _files = [];

  Future<List<String>> selectImages() async {
    //이미지 선택 , 여러 이미지 선택 , 해상도 1024로 맞춰주기
    List<XFile> images =
        await ImagePicker().pickMultiImage(maxHeight: 1024, maxWidth: 1024);
    //안드로이드든 ios이든 선택된 이미지에 접근할 수 있는 경로를 가지고 있는 것이 xfile
    //여러개 사진을 받아 올 수 있으므로 List 형식으로

//map - list의 요소 수 만큼 반복문을 실행한다.
//e는 xfile 객체
//경로를 문자열로 받기 위해
    return images.map((e) => e.path).toList();
  }

  List<Widget> selectedImageList() {
    final feedStatus = context.watch<FeedState>().feedStatus;

    //_files가 가지고 있는 list에 들어 있는 이미지에 접근 가능한 문자열 경로 하나 하나 가져와서
    return _files.map((data) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Stack(children: [
          ClipRRect(
            child: Image.file(
              File(data),
              fit: BoxFit.cover,
              //boxfit 틀에 맞춰서 원본을 확대 축소해준다. // 그래서 잘릴 수 있다.
              height: MediaQuery.of(context).size.height * 0.4,
              width: 280,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: feedStatus == FeedStatus.submitting
                  ? null
                  : () {
                      setState(() {
                        _files.remove(data);
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(60),
                ),
                height: 30,
                width: 30,
                child: Icon(
                    color: Colors.black.withOpacity(0.6),
                    size: 30,
                    Icons.highlight_remove_outlined),
              ),
            ),
          )
        ]),
      );
    }).toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedStatus = context.watch<FeedState>().feedStatus;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //transparent 투명한
        //그림자 0
        elevation: 0,
        //뒤로 가기 버튼 사라지기
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed:
                (_files.length == 0 || feedStatus == FeedStatus.submitting)
                    ? null
                    : () async {
                        try {
                          FocusScope.of(context).unfocus();
                          await context.read<FeedProvider>().uploadFeedd(
                                files: _files,
                                desc: _textEditingController.text,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Feed를 등록했습니다.')),
                          );
                          //다른 클래스이므로
                          widget.onFeedUploaded();
                        } on CustomException catch (e) {
                          errorDialogWidget(context, e);
                        }
                      },
            child: Text('Feed'),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(children: [
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                value: feedStatus == FeedStatus.submitting ? null : 1,
                color: feedStatus == FeedStatus.submitting
                    ? Colors.red
                    : Colors.transparent,
              ),
              SingleChildScrollView(
                //수직으로 스크롤 가능하므로
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      //geturedetector 가능 설정할 수 있는 옵션이 더 많다. but inkwell은 터치했을 때 애니메이션이 있다.
                      onTap: feedStatus == FeedStatus.submitting
                          ? null
                          : () async {
                              final _images = await selectImages();
                              //빈 리스트에 추가를 할 순 있다.
                              setState(() {
                                _files.addAll(_images);
                              });
                            },
                      child: Container(
                        height: 80,
                        width: 80,
                        child: const Icon(Icons.upload),
                        //Opacity 불투명도
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),

                    //[1,2,3]
                    //1,
                    //2,
                    //3,
                    //추가 하는 방법은 ...
                    ...selectedImageList(),
                  ],
                ),
              ),
              if (_files.isNotEmpty)
                TextFormField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                      hintText: '내용을 입력하세요...',
                      //외곽선 없애기
                      border: InputBorder.none),
                  maxLines: 5,
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
