import 'package:flutter/cupertino.dart';

class CodeItemModel extends ChangeNotifier {
  CodeItemModel({
    required this.index,
    String? initText,
    FocusNode? focusNode,
    TextEditingController? controller,
  }) {
    _text = initText ?? _text;
    this.focusNode = focusNode ?? FocusNode();
    this.focusNode.addListener(notifyListeners);

    this.controller = controller ?? TextEditingController();
    this.controller.addListener(() {
      String value = this.controller.text;
      if (_text != value) {
        _text = value;
        notifyListeners();
      }
    });
  }

  final int index;

  late TextEditingController controller;

  String _text = '';

  String get text => _text;

  set text(String value) {
    controller.text = value;
  }

  late FocusNode focusNode;

  bool get hasFocus => focusNode.hasFocus;

  requestFocus() {
    focusNode.requestFocus();
  }

  unFocus() {
    focusNode.unfocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}
