import 'package:flutter/material.dart';

import 'package:termare/termare.dart';
import 'package:termare_example/ssh.dart';

void main() {
  runApp(SshMyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        // child: Material(
        //   child: Column(
        //     children: [
        //       Text(
        //         '测试字体 Test Font' * 3,
        //         style: TextStyle(
        //           fontFamily: 'packages/termare/UbuntuMono',
        //           // fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       Text(
        //         '测试字体 Test Font' * 3,
        //         style: TextStyle(
        //           fontFamily: 'packages/termare/DroidSansMono',
        //         ),
        //       ),
        //       Text(
        //         '测试字体 Test Font' * 3,
        //         style: TextStyle(
        //           fontFamily: 'packages/termare/SourceCodePro',
        //         ),
        //       ),
        //       Text(
        //         '测试字体 Test Font' * 3,
        //         style: TextStyle(
        //           fontFamily: 'packages/termare/sarasa-mono-sc-bold',
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        child: TermarePty(),
      ),
    );
  }
}
