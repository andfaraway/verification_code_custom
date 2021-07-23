import 'package:flutter/material.dart';
import 'package:verification_code_custom/verification_code_custom.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Verification_code_custom'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: VerificationCodeCustom(textChanged: (list) {
              print(list);
              String result = '';
              for(String str in list){
                result += str;
              }
            },),
          ),
        ),
      ),
    );
  }
}
