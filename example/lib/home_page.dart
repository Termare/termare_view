import 'dart:convert';

import 'package:example/float_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:termare_view/termare_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AnimationMixin {
  Animation<double> height;
  TermareController termareController = TermareController(
    showBackgroundLine: true,
  );

  @override
  void initState() {
    super.initState();
    startTest();

    height = 500.0.tweenTo(500.0).animatedBy(controller);
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
    // SequencesTest.testColorText(termareController);
    // termareController.write('啊123撒大声地abc');
    // termareController.write('123');

    // // print('');
    // for (int i = 0; i < 1000; i++) {
    //   termareController.write('$i\n\r');
    // }
    // termareController.write('1000\n\r');
    termareController.write('1001\n\r');
    termareController.write(utf8.decode([
      37,
      56,
      55,
      54,
      53,
      52,
      51,
      50,
      49,
      48,
      27,
      91,
      63,
      49,
      108,
      27,
      62,
      27,
      91,
      63,
      50,
      48,
      48,
      52,
      108,
      13,
      13,
      10,
      48
    ]));
    // termareController.write('123456\x08\x08\x08\x08\x08\x1b[3P\n');

    // termareController.write('123456\x08\x08\x08\x08\x08\x1b[3@999\n');

    // var data = utf8.decode([8, 8, 8, 27, 91, 49, 80, 108, 115]);
    // termareController.write('~ \$ apt$data\n');

    // termareController.write(
    //   '~ \$ git clone https://github.com/nightmare-space/app_manager.git',
    // );
    return;
  }

  void expand() {
    height = 500.0
        .tweenTo(MediaQuery.of(context).size.height)
        .animatedBy(controller);
    controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (key) {
        print('->$key');
      },
      child: Visibility(
        visible: true,
        child: SafeArea(
          child: Stack(
            children: [
              TermareView(
                keyboardInput: (value) {
                  print('value${value.codeUnits}');
                  termareController.enableAutoScroll();
                  termareController.write(value);
                },
                controller: termareController,
              ),
              // FloatView(
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(12),
              //     child: SizedBox(
              //       width: MediaQuery.of(context).size.width,
              //       height: height.value,
              //       child: Column(
              //         children: [
              //           Container(
              //             height: 24,
              //             decoration: BoxDecoration(
              //               color: Color(0xffe8ebf0),
              //             ),
              //             child: Padding(
              //               padding: EdgeInsets.symmetric(horizontal: 8),
              //               child: Row(
              //                 children: [
              //                   Container(
              //                     width: 16,
              //                     height: 16,
              //                     decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.circular(8),
              //                       color: Color(0xffee695e),
              //                     ),
              //                   ),
              //                   SizedBox(
              //                     width: 6,
              //                   ),
              //                   Container(
              //                     width: 16,
              //                     height: 16,
              //                     decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.circular(8),
              //                       color: Color(0xfff4be4f),
              //                     ),
              //                   ),
              //                   SizedBox(
              //                     width: 6,
              //                   ),
              //                   GestureDetector(
              //                     onTap: () {
              //                       expand();
              //                     },
              //                     child: Container(
              //                       width: 16,
              //                       height: 16,
              //                       decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(8),
              //                         color: Color(0xff63c957),
              //                       ),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           Expanded(
              //             child: TermareView(
              //               keyboardInput: (value) {
              //                 print('value${value.codeUnits}');
              //                 termareController.enableAutoScroll();
              //                 termareController.write(value);
              //               },
              //               controller: termareController,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
