import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dartssh/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare/termare.dart';

const host = 'ssh://39.107.248.176:22';
const username = 'root';
const password = '';

class SshMyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xterm.dart demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TermareController controller;
  SSHClient client;

  @override
  void initState() {
    super.initState();
    final Size size = window.physicalSize;
    print(size);
    print(window.devicePixelRatio);
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.letterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.letterWidth;
    print('< row : $row column : $column>');
    controller = TermareController(
      environment: Platform.isIOS
          ? {}
          : {
              'TERM': 'screen-256color',
              'PATH': '/data/data/com.nightmare/files/usr/bin:' +
                  Platform.environment['PATH'],
            },
      rowLength: row - 2,
      columnLength: column - 2,
    );

    connect();
  }

  void connect() {
    controller.write('connecting $host...');
    client = SSHClient(
      hostport: Uri.parse(host),
      login: username,
      print: print,
      termWidth: 80,
      termHeight: 25,
      termvar: 'xterm-256color',
      getPassword: () => Uint8List.fromList(utf8.encode(password)),
      response: (transport, data) {
        controller.write(data);
      },
      success: () {
        controller.write('connected.\n');
      },
      disconnected: () {
        controller.write('disconnected.');
      },
    );
  }

  void onInput(String input) {
    // client?.sendChannelData(utf8.encode(input));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TermareView(
          controller: controller,
          keyboardInput: (String data) {
            client?.sendChannelData(Uint8List.fromList(utf8.encode(data)));
          },
        ),
      ),
    );
  }
}
