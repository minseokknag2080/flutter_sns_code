import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/providers/auth/auth_provider.dart';
import 'package:sns_clonecode/screens/signin_screen.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';
import 'package:validators/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _passwordEditingController = TextEditingController();
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _emailditingController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isEnabled = true;

  Uint8List?
      _image; //unsinged inteager 이미지 동영상 같은 바이너리 데이터 사용할 때 // 프로필 사진은 필수가 아니라 선택이기 때문에 nullable

  Future<void> selectImage() async {
    ImagePicker imagePicker = new ImagePicker(); //객체 생성
    XFile? file = await imagePicker.pickImage(
      //갤러리에 접근할 수 있게, 사진 선택안 할 수 있으므로 nullable
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null) {
      Uint8List uint8list =
          await file.readAsBytes(); //setState에 async 쓰면 이미지를 2번 바꾸면 오류 난다.
      setState(() {
        _image = uint8list;
      });

      //이미지 선택
      _image = await file.readAsBytes();
    }
  }

//editingcontroller 해당화면이 dispose 되어도 자동으로 사라지지 않는다.
  @override
  void dispose() {
    _emailditingController.dispose();
    _nameEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //back 버튼이 눌렸을 때 어떤 동작을 하는지 지정하는 역할
      //back 잠금
      onWillPop: () async => false,
      child: GestureDetector(
        //현재 포커스가 어디에 위치에 있는지 찾아 가는 것 -> 그 포커스를 없애주는 역할 unfocus()
        onTap: () => FocusScope.of(context).unfocus(),

        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _globalKey,
                autovalidateMode: _autovalidateMode,
                child: ListView(
                  reverse: true, //역정렬
                  shrinkWrap: true, //필요한 곳만 차지하고 정 가운데로. //오그라들다 줄다 감소하다.
                  children: [
                    //로고
                    SvgPicture.asset(
                      'assets/images/ic_instagram.svg',
                      height: 64,
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //프로필 사진
                    Container(
                      alignment: Alignment.center,
                      //decoration: BoxDecoration(color: Colors.red),
                      child: Stack(
                        children: [
                          _image == null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage:
                                      AssetImage('assets/images/profile.png'),
                                )
                              : CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(
                                      _image!), //uint8list로 이미지 만들어 주는 위젯
                                ),
                          Positioned(
                            left: 80,
                            bottom: -10,
                            child: IconButton(
                              onPressed: _isEnabled
                                  ? () async {
                                      await selectImage();
                                    }
                                  : null,
                              icon: Icon(Icons.add_a_photo),
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 30,
                    ),

                    //이메일
                    TextFormField(
                      enabled: _isEnabled,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        filled: true, //색상 족용할지 여부 /fillcolor 배경 색
                      ),
                      //검증로직
                      validator: (value) {
                        //text가 문자열로 입력된다.

                        //검증로직이 실패할 경우 3가지
                        //1.아무것도 입력 x 2.공백만 입력 3.이메일 형식이 아닐 때
                        //'     asd     '.trim() == 'asd'  //좌우 끝 부분의 공백을 없애준다.
                        //isEmpty -> 빈 문자열인지 ture false 로
                        if (value == null ||
                            value.trim().isEmpty ||
                            !isEmail(value.trim())) {
                          return '이메일을 입력해주세요.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //이름
                    TextFormField(
                      enabled: _isEnabled,
                      controller: _nameEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.account_circle),
                        filled: true, //색상 족용할지 여부 /fillcolor 배경 색
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요.';
                        }
                        if (value.length < 3 || value.length > 10) {
                          return '입력은 최소 3글자, 최대 10글자 까지 입력 가능합니다.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //패스워드
                    TextFormField(
                      enabled: _isEnabled,
                      controller: _passwordEditingController,
                      //글자 감추기
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        filled: true, //색상 족용할지 여부 /fillcolor 배경 색
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '패스워드를 입력해주세요.';
                        }
                        if (value.length < 6) {
                          return '패스워드는 6글자 이상 입력해주세요.'; //firebase 패스워드 6글자 이상
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //패스워트 확인
                    TextFormField(
                      enabled: _isEnabled,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        filled: true, //색상 족용할지 여부 /fillcolor 배경 색
                      ),
                      validator: (value) {
                        if (_passwordEditingController.text != value) {
                          return '패스워드가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //회원가입 버튼
                    ElevatedButton(
                      onPressed: _isEnabled
                          ? () async {
                              final form = _globalKey.currentState;

                              if (form == null || !form.validate()) {
                                return;
                              }

                              setState(() {
                                //회원가입 버튼이 눌렸을 때 _isenabled 버튼에 false 가 전달된다.
                                _isEnabled = false;
                                _autovalidateMode = AutovalidateMode.always;
                              });

                              //회원가입 로직 진행
                              try {
                                await context.read<Auth_Provider>().signUp(
                                    email: _emailditingController.text,
                                    name: _nameEditingController.text,
                                    password: _passwordEditingController.text,
                                    profileImage: _image);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SigninScreen(),
                                  ),
                                );

                                //회원가입 로직이 끝나고 난 다음
                                //회원가입 화면이 scaffold 화면 아래에 작성되어 있다. scaffold에 snackbar을 표현하기 위해서
                                //scaffold의 context를 찾아 가는 것이다.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('인증 메일을 전송했습니다.'),
                                    duration: Duration(
                                      seconds: 120,
                                    ),
                                  ),
                                );
                              } on CustomException catch (e) {
                                setState(() {
                                  _isEnabled = true;
                                });
                                errorDialogWidget(context, e);
                              }
                            }
                          : null,
                      child: Text('회원가입'),
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    TextButton(
                      onPressed: _isEnabled
                          ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SigninScreen(),
                              ))
                          : null,
                      child: Text(
                        '이미 회원이신가요? 로그인 하기',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ].reversed.toList(), //다시 역정렬 // reverse의 반환 타입은 iterable
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
