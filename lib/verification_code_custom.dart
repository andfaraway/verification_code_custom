import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class VerificationCodeCustom extends StatefulWidget {
  ///验证码数组
  final Function(List<String>) textChanged;

  ///itemCount 验证码长度：4或6，默认是6
  final int itemCount;

  ///是否自动获取焦点
  final autofocus;

  VerificationCodeCustom(
      {required this.textChanged, this.itemCount = 4, this.autofocus = true});

  @override
  _VerificationCodeCustomState createState() =>
      _VerificationCodeCustomState(this.textChanged, this.itemCount);
}

class _VerificationCodeCustomState extends State<VerificationCodeCustom> {
  Function textChanged;
  final int itemCount;

  _VerificationCodeCustomState(this.textChanged, this.itemCount);

  final double width = 40;

  List<FocusNode> focusNodeList = [];
  List<String> textList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (int i = 0; i < itemCount; i++) {
      FocusNode focusNode = FocusNode();
      focusNodeList.add(focusNode);
      textList.add('');
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _textFieldList(),
          ),
          GestureDetector(
            onTap: () {
              for (int i = textList.length - 1; i >= 0; i--) {
                String text = textList[i];

                if ((text.length > 0 && text != ' ') || i == 0) {
                  if (i < textList.length - 1 && i != 0) {
                    _getFocus(focusNodeList[i + 1]);
                    if (textList[i + 1].length == 0) {
                      textList[i + 1] = ' ';
                    }
                  } else if (i == textList.length - 1) {
                    _getFocus(focusNodeList[i]);
                  } else {
                    if(widget.autofocus){
                      _getFocus(focusNodeList[1]);
                    }else{
                      _getFocus(focusNodeList[0]);
                    }
                  }
                  break;
                }
              }
            },
            child: Container(
              color: Colors.transparent,
              height: 60,
              width: MediaQuery.of(context).size.width,
            ),
          )
        ],
      ),
    );
  }

  _textFieldList() {
    List<Widget> list = [];
    list.add(Container(
      width: width,
      child:
      _textField(index: 0, text: textList[0], focusNode: focusNodeList[0]),
    ));
    list.add(Container(
      width: width,
      child:
      _textField(index: 1, text: textList[1], focusNode: focusNodeList[1]),
    ));
    list.add(Container(
      width: width,
      child:
      _textField(index: 2, text: textList[2], focusNode: focusNodeList[2]),
    ));
    list.add(Container(
      width: width,
      child:
      _textField(index: 3, text: textList[3], focusNode: focusNodeList[3]),
    ));

    if (itemCount == 6) {
      list.add(Container(
        width: width,
        child: _textField(
            index: 4, text: textList[4], focusNode: focusNodeList[4]),
      ));
      list.add(Container(
        width: width,
        child: _textField(
            index: 5, text: textList[5], focusNode: focusNodeList[5]),
      ));
    }
    return list;
  }

  _textField(
      {required int index,
        required String text,
        required FocusNode focusNode}) {
    TextEditingController _controller = TextEditingController(text: text);
    _controller.selection = TextSelection.fromPosition(
        TextPosition(affinity: TextAffinity.downstream, offset: text.length));

    return TextField(
      controller: _controller,
      focusNode: focusNode,
      autofocus: index == 0 ? widget.autofocus : false,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Color(0xff8C8C8C), fontSize: 14),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFD3B60), width: 1)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffDADADA), width: 1)),
        fillColor: Colors.transparent,
        filled: true,
      ),
      scrollPadding: EdgeInsets.all(200),
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Color(0xFF333333), fontSize: 22, fontWeight: FontWeight.bold),
      cursorWidth: 0,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.length > 1) {
          if (value.substring(0, 1) == ' ') {
            value = value.substring(1, value.length);
          }
        }
        //输入非数字，不变
        if (!RegExp('^[0-9]*\$').hasMatch(value)) {
          setState(() {});
          return;
        } else {}

        String oldStr = textList[index];

        //输入值为复制的验证码
        if (value.length == itemCount || value.length == itemCount + 1) {
          if (value.length == itemCount + 1) {
            if (oldStr == value.substring(0, 1)) {
              //删除第一位
              value = value.substring(1);
            } else {
              //删除最后一位
              value = value.substring(0, value.length - 1);
            }
          }

          //所有重新赋值
          for (int i = 0; i < textList.length; i++) {
            textList[i] = value.substring(i, i + 1);
          }
          _loseFocus(focusNodeList[index]);
          setState(() {});
          textChanged(textList);
          return;
        }

        //删除字符
        if (value.length == 0) {
          //焦点前移
          if (index > 0) {
            if (index == textList.length - 1) {
              //最后一位
              if (textList[index] == ' ') {
                _getFocus(focusNodeList[index - 1]);
                textList[index - 1] = ' ';
              }
            } else {
              _getFocus(focusNodeList[index - 1]);
              textList[index - 1] = ' ';
            }
          }
          textList[index] = ' ';

          setState(() {});
          textChanged(textList);
        } else {
          //赋值
          textList[index] = value;
          //焦点后移
          if (index < focusNodeList.length - 1) {
            _getFocus(focusNodeList[index + 1]);
            textList[index + 1] = ' ';
          } else {
            _loseFocus(focusNodeList[index]);
          }
          setState(() {});
          textChanged(textList);
        }
      },
    );
  }

  ///获取焦点
  _getFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  ///失去焦点
  _loseFocus(FocusNode focusNode) {
    focusNode.unfocus();
  }
}
