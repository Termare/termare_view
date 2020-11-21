import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh/client.dart';
import 'package:flutter/material.dart';
import 'package:termare/termare.dart';

const host = 'ssh://39.107.248.176:22';
const username = 'root';
const password = 'mys906262255.';

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
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TermareController controller = TermareController();
  SSHClient client;

  @override
  void initState() {
    super.initState();
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
        ),
      ),
    );
  }
}
