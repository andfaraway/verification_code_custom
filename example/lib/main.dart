import 'package:flutter/material.dart';
import 'package:verification_code_custom/verification_code_custom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Verification_code_custom'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: verificationCodeWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget verificationCodeWidget(){
    return VerificationCodeCustom(
      textResult: (text) {
        /// do something
      },
    );
  }
}


