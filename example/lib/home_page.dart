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
      // showBackgroundLine: true,
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
    SequencesTest.testColorText(termareController);
    termareController.write('啊123撒大声地abc');
    termareController.write('123');

    print('');
    for (int i = 0; i < 100; i++) {
      termareController.write('$i\n');
    }
    termareController.write('123456\x08\x08\x08\x08\x08\x1b[3P\n');

    termareController.write('123456\x08\x08\x08\x08\x08\x1b[3@999\n');

    var data = utf8.decode([8, 8, 8, 27, 91, 49, 80, 108, 115]);
    termareController.write('~ \$ pwd$data');
    // controller.write(utf8.decode([27, 91, 63, 50, 48, 48, 52, 108]));
    // controller.write(utf8.decode([13]));
    // for (int i = 0; i < 49; i++) {
    //   print(i);
    //   controller.write('*');
    // }
    return;
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
              FloatView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: height.value,
                    child: Column(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xffe8ebf0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xffee695e),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xfff4be4f),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    expand();
                                  },
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xff63c957),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TermareView(
                            keyboardInput: (value) {
                              print('value${value.codeUnits}');
                              termareController.enableAutoScroll();
                              termareController.write(value);
                            },
                            controller: termareController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
