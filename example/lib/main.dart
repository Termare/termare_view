import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/termare_view.dart';

import 'home_page.dart';

void main() {
  for (int i = 0; i < 256; i++) {
    print('\x1b[48;5;$i\m$i     \x1b[0m');
  }
  print('\x1b[2J');
  runAppWithTool(
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
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Color(0xfff5f5f7),
        resizeToAvoidBottomInset: true,
        // body: SafeArea(
        //   // width: 100,
        //   // height: 100,
        //   child: TermareView(
        //     keyboardInput: (value) {
        //       print('value${value.codeUnits}');
        //       controller.enableAutoScroll();
        //       controller.write(value);
        //     },
        //     controller: controller,
        //   ),
        // ),
      ),
    );
  }
}

Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
  yield DefaultMaterialLocalizations.delegate;
  yield DefaultWidgetsLocalizations.delegate;
}

void runAppWithTool(Widget app) {
  runApp(Directionality(
    child: MediaQuery(
      data: MediaQueryData.fromWindow(window),
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: _localizationsDelegates.toList(),
        child: Stack(
          children: [
            app,
            HomePage(),
          ],
        ),
      ),
    ),
    textDirection: TextDirection.ltr,
  ));
}
