import 'dart:io';

import 'package:flutter/services.dart';
import 'package:verification_code_custom/verification_code_custom.dart';

class CustomTextInputMask extends TextInputFormatter {
  CustomTextInputMask({required this.codeType, required this.copyCallBack, required this.onChanged}) : super();

  final CodeType codeType;
  final ValueChanged<String> copyCallBack;
  final ValueChanged<String> onChanged;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String oldText = oldValue.text;
    String newText = newValue.text;
    testLog('CustomTextInputMask: $oldText => $newText');

    if (newText.length - oldText.length > 1) {
      String text = newText.substring(oldValue.text.length);
      copyCallBack(text);
      return oldValue;
    }

    if (newText.length >= 2) {
      newText = newText.substring(newText.length - 1, newText.length);
    }

    testLog('newText = $newText,${codeType.regExp.hasMatch(newText)}');

    if (!codeType.regExp.hasMatch(newText)) {
      return oldValue;
    }

    if (newText.isNotEmpty) {
      onChanged(newText);
    }else{
      if(Platform.isIOS){
        onChanged('');
      }
    }
    return TextEditingValue(text: newText);
  }
}
