import 'package:flutter/material.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';

void errorDialogWidget(BuildContext context, CustomException e) {
  showDialog(
    context: context,
    barrierDismissible: false,
    //확인버튼이 아닌 다른 영역을 눌러더 닫히지 않는다.
    builder: (context) {
      return AlertDialog(
        //에러 코드
        title: Text(e.code),
        //에러 내용
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context)
            //버튼을 클릭하면 창이 닫힌다.
            ,
            child: Text('확인'),
          ),
        ],
      );
    },
  );
}
