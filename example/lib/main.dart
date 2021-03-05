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
    showBackgroundLine: true,
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

    SequencesTest.testCSI(controller);
    SequencesTest.testColorText(controller);
    SequencesTest.testColorText(controller);
    // SequencesTest.testChinese(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SizedBox(
        // width: 100,
        // height: 100,
        child: TermareView(
          keyboardInput: (value) {},
          controller: controller,
        ),
      ),
    );
  }
}
