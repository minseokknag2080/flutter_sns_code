import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/providers/auth/auth_provider.dart';
import 'package:sns_clonecode/providers/auth/auth_state.dart';
import 'package:sns_clonecode/screens/signup_screen.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';
import 'package:validators/validators.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _passwordEditingController = TextEditingController();
  TextEditingController _emailditingController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isEnabled = true;

//editingcontroller 해당화면이 dispose 되어도 자동으로 사라지지 않는다.
  @override
  void dispose() {
    _emailditingController.dispose();
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

                    //로그인 버튼
                    ElevatedButton(
                      onPressed: _isEnabled
                          ? () async {
                              final form = _globalKey.currentState;

                              if (form == null || !form.validate()) {
                                return;
                              }

                              setState(() {
                                //로그인 버튼이 눌렸을 때 _isenabled 버튼에 false 가 전달된다.
                                _isEnabled = false;
                                _autovalidateMode = AutovalidateMode.always;
                              });

                              //로그인 로직 진행
                              try {
                                logger.d(context.read<AuthState>().authStatus);
                                //로그인 로직 수행 전에는 unauthenticated

                                await context.read<Auth_Provider>().signIn(
                                      email: _emailditingController.text,
                                      password: _passwordEditingController.text,
                                    );

                                logger.d(context.read<AuthState>().authStatus);
                                //로그인 로직 수행 전에는 authenticated
                              } on CustomException catch (e) {
                                setState(() {
                                  _isEnabled = true;
                                });
                                errorDialogWidget(context, e);
                              }
                            }
                          : null,
                      child: Text('로그인'),
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    TextButton(
                      onPressed: _isEnabled
                          //push로 화면이동을 하면 계속해서 화면이 쌓인다.
                          //pushReplacement 이용하여 화면 이동을 하면, 그전 화면 위치에 새로운 화면을 덮어 쓰기 때문에
                          //화면이 쌓이지 않는다.
                          ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ))
                          : null,
                      child: Text(
                        '회원이 아니신가요? 회원가입 하기',
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
