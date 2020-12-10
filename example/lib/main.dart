import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_ssh/termare_ssh.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        title: const Text(
          'Termare Example',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                color: const Color(0xfff9fafc),
                onPressed: () {
                  Navigator.of(context).push<TermarePty>(
                    MaterialPageRoute(
                      builder: (_) {
                        return const TermarePty();
                      },
                    ),
                  );
                },
                child: const Text('Termare-Pty'),
              ),
              FlatButton(
                color: const Color(0xfff9fafc),
                onPressed: () {
                  Navigator.of(context).push<TermarePty>(
                    MaterialPageRoute(
                      builder: (_) {
                        return const TermareSsh();
                      },
                    ),
                  );
                },
                child: const Text('Termare-Ssh'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
