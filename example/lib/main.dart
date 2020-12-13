import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/termare_view.dart';

void main() {
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
    controller.write('hello termare_view\n');
    controller.write('\x1B[1;31mhello termare_view\x1B[0m\n');
    controller.write('\x1B[1;32mhello termare_view\x1B[0m\n');
    SequencesTest.testColorText(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TermareView(
        controller: controller,
      ),
    );
  }
}
