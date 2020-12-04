import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_listener.dart';
import 'termare.dart';

void main() {
  runApp(
    MaterialApp(
      home: Test(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  FocusNode node = FocusNode(
      skipTraversal: true,
      onKey: (FocusNode node, key) {
        print('key->$key  node->$node');
      });
  FocusAttachment attachment;
  @override
  void initState() {
    super.initState();

    attachment = node.attach(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) {
                return TestPage();
              },
            ),
          );
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            focusNode: node,
          ),
          FlatButton(
            onPressed: () {
              node.unfocus();
              node.dispose();
              attachment.detach();
              // widget.focusNode.requestFocus();
              // _focusAttachment.detach();
              // widget.focusNode.attach(context);
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   debugDumpFocusTree();
              // });
              print(FocusManager.instance.primaryFocus);
              // print(widget.focusNode.attach(context).reparent());
            },
            child: const Text(
              '按钮',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      },
      child: InputListener(
        focusNode: _focusNode,
        onkey: (key) {
          print('key -> $key');
        },
        child: Text('data'),
      ),
    );
  }
}
