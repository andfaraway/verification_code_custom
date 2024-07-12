import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verification_code_custom/src/custom_text_input_mask.dart';
import 'package:verification_code_custom/src/code_item_model.dart';

typedef ItemBuilder = Widget Function(String text, bool isSelected);

class VerificationCodeCustom extends StatefulWidget {
  final ItemBuilder? itemBuilder;

  final CodeType codeType;

  /// 返回结果
  final Function(String) textResult;

  ///itemCount 验证码长度：4或6，默认是4
  final int itemCount;

  ///是否自动获取焦点
  final bool autofocus;

  const VerificationCodeCustom({
    super.key,
    required this.textResult,
    this.itemBuilder,
    this.itemCount = 4,
    this.autofocus = false,
    this.codeType = CodeType.num,
  });

  @override
  State<VerificationCodeCustom> createState() => _VerificationCodeCustomState();
}

class _VerificationCodeCustomState extends State<VerificationCodeCustom> {
  late Function textChanged;

  _VerificationCodeCustomState();

  List<CodeItemModel> items = [];

  late CodeItemModel currentModel;

  @override
  void initState() {
    super.initState();

    items = List.generate(widget.itemCount, (index) => CodeItemModel(index: index));

    currentModel = items.first;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.autofocus) {
        Future.delayed(const Duration(seconds: 1),(){
          currentModel.requestFocus();
          setState(() {});
        });
      }
    });

    // SystemChannels.lifecycle.setMessageHandler((message) async {
    //   print('message = $message');
    //   return message;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      // autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            print('backspace');
            if(Platform.isAndroid){
              onChanged('');
            }
          }
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) => _buildItem(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(CodeItemModel model) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (detail) {
        _showCopyWidget(
            pasteText: 'Paste',
            offset: detail.globalPosition - detail.localPosition,
            onTap: () async {
              currentModel.unFocus();
              String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
              inputCopyText(text);
            });
      },
      onTap: () {
        model.requestFocus();
        currentModel = model;
      },
      child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            Widget child = const SizedBox.shrink();
            if (widget.itemBuilder != null) {
              child = widget.itemBuilder!.call(model.text, model.hasFocus);
            } else {
              String text = model.text;
              Color color = model.hasFocus ? Colors.redAccent : Colors.grey;
              child =  Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
                alignment: Alignment.center,
                child: Text(text),
              );
            }
            return Stack(
              children: [
                SizedBox(
                  width: 1,
                  height: 1,
                  child: TextField(
                    enableInteractiveSelection: false,
                    controller: model.controller,
                    focusNode: model.focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CustomTextInputMask(
                        codeType: widget.codeType,
                        copyCallBack: inputCopyText,
                        onChanged: onChanged,
                      ),
                    ],
                  ),
                ),
                child,
              ],
            );
          }),
    );
  }

  onChanged(value) {
    testLog('onChanged = $value');
    currentModel.text = value;
    if (value.isNotEmpty) {
      next();
    } else {
      back();
    }
  }

  back() {
    if (currentModel.index > 0) {
      items[currentModel.index - 1].requestFocus();
      currentModel = items[currentModel.index - 1];
    }
    temp = true;
  }

  bool temp = true;

  next() {
    if (currentModel.index < widget.itemCount - 1) {
      items[currentModel.index + 1].requestFocus();
      currentModel = items[currentModel.index + 1];
    }

    for (final i in items) {
      if (i.text.isEmpty) {
        testLog('i => ${i.text},${i.index}');
        return;
      }
    }

    if (currentModel.index == widget.itemCount - 1) {
      if (temp) {
        hideKeyboard(context);
        temp = false;
      } else {
        temp = true;
      }
    }
    widget.textResult(items.map((e) => e.text).toList().join(''));
  }

  inputCopyText(String text) {
    if (!widget.codeType.copyRegExp(widget.itemCount).hasMatch(text)) {
      return;
    }
    testLog('input copy text:$text');
    for (int i = 0; i < text.length; i++) {
      items[i].controller.text = text.substring(i, i + 1);
    }
    hideKeyboard(context);
    widget.textResult(text);
  }

  _showCopyWidget({required String pasteText, required Offset offset, required VoidCallback onTap}) {
    showDialog(
        context: context,
        useSafeArea: false,
        barrierColor: Colors.transparent,
        anchorPoint: offset,
        builder: (context) {
          double dx = offset.dx;
          double dy = offset.dy;

          double screenWidth = MediaQuery.of(context).size.width;
          // double screenHeight = MediaQuery.of(context).size.height;

          if (dx > screenWidth - 80) {
            dx -= 20;
          }
          dy -= 35;
          return Stack(
            children: [
              Positioned(
                top: dy,
                left: dx,
                child: GestureDetector(
                  onTap: () {
                    onTap();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.1), offset: Offset.zero, blurRadius: 4, spreadRadius: 2),
                    ]),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: const Text('Paste'),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

enum CodeType { num, char, all }

extension CodeTypeEx on CodeType {
  RegExp get regExp => switch (this) {
        CodeType.num => RegExp(r'^[0-9]?$'),
        CodeType.char => RegExp(r'^[a-zA-Z]?$'),
        CodeType.all => RegExp(r'^[0-9a-zA-Z]?$'),
      };

  RegExp copyRegExp(int length) => switch (this) {
        CodeType.num => RegExp('^[0-9]{$length}\$'),
        CodeType.char => RegExp('^[a-zA-Z]{$length}\$'),
        CodeType.all => RegExp('^[0-9a-zA-Z]{$length}\$'),
      };
}

testLog(String text) => log(text);
