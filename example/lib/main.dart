import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/termare_view.dart';

void main() {
  for (int i = 0; i < 256; i++) {
    print('\x1b[48;5;$i\m$i     \x1b[0m');
  }
  print('\x1b[2J');
  runApp(
    MaterialApp(
      home: Example(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  TermareController controller = TermareController(
      // showBackgroundLine: true,
      );

  @override
  void initState() {
    super.initState();
    startTest();
    // controller.write('hello termare_view\n');
    // controller.write('\x1B[1;31mhello termare_view\x1B[0m\n');
    // SequencesTest.testDECSEL(controller);
    // SequencesTest.testColorText(controller);
    // SequencesTest.testOSC(controller);
    // controller.write('      asdad█████阿                    |\n');
    // SequencesTest.testColorText(controller);
  }

  Future<void> startTest() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // SequencesTest.testC1(controller);
    // SequencesTest.testC0(controller);
    // SequencesTest.testC1(controller);
    // SequencesTest.testDECSEL(controller);

    // SequencesTest.testCSI(controller);
    SequencesTest.testColorText(controller);
    controller.write('啊123撒大声地abc');
    controller.write('\x1b[7m123');

    print('');
    for (int i = 0; i < 100; i++) {
      controller.write('$i\n');
    }
    // controller.write(utf8.decode([27, 91, 63, 50, 48, 48, 52, 108]));
    // controller.write(utf8.decode([13]));
    // for (int i = 0; i < 49; i++) {
    //   print(i);
    //   controller.write('*');
    // }
    return;
    controller.write(utf8.decode([
      27,
      91,
      49,
      109,
      27,
      91,
      51,
      109,
      37,
      27,
      91,
      50,
      51,
      109,
      27,
      91,
      49,
      109,
      27,
      91,
      48,
      109,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32,
      32
    ]));
    // controller.write(utf8.decode([13]));
    // controller.write(utf8.decode([32]));
    // controller.write(utf8.decode([13]));
    // controller.write(utf8.decode([27, 107, 126, 27, 92]));
    // controller.write(utf8.decode([13]));
    // controller.write(utf8.decode([
    //   27,
    //   91,
    //   48,
    //   109,
    //   27,
    //   91,
    //   50,
    //   51,
    //   109,
    //   27,
    //   91,
    //   50,
    //   52,
    //   109,
    //   27,
    //   91,
    //   74,
    //   27,
    //   91,
    //   48,
    //   49,
    //   59,
    //   51,
    //   50,
    //   109,
    //   226,
    //   158,
    //   156,
    //   32,
    //   32,
    //   27,
    //   91,
    //   51,
    //   54,
    //   109,
    //   126,
    //   27,
    //   91,
    //   48,
    //   48,
    //   109,
    //   32,
    //   27,
    //   91,
    //   75,
    //   27,
    //   91,
    //   63,
    //   49,
    //   104,
    //   27,
    //   61,
    //   27,
    //   91,
    //   63,
    //   50,
    //   48,
    //   48,
    //   52,
    //   104
    // ]));
    // controller.write('A');
    // controller.write('\x1b[0;36r');
    // controller.write('\x1b[2A');
    // controller.write('\x1b[3C');
    // Future.delayed(const Duration(milliseconds: 600), () {
    //   controller.write('\x1b[K');
    // });
    // controller.write('\x1b[37;0f');
    // SequencesTest.test256Color(controller);

    // SequencesTest.testChinese(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        // width: 100,
        // height: 100,
        child: TermareView(
          keyboardInput: (value) {
            print('value${value.codeUnits}');
            controller.enableAutoScroll();
            controller.write(value);
          },
          controller: controller,
        ),
      ),
    );
  }
}
