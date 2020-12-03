import 'dart:io';
import 'dart:ui';
import 'package:dart_pty/dart_pty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare/termare.dart';

class TermarePty extends StatefulWidget {
  const TermarePty({
    Key key,
    this.controller,
    this.unixPtyC,
    this.autoFocus = false,
  }) : super(key: key);
  final TermareController controller;
  final UnixPtyC unixPtyC;
  final bool autoFocus;
  @override
  _TermarePtyState createState() => _TermarePtyState();
}

class _TermarePtyState extends State<TermarePty> with TickerProviderStateMixin {
  TermareController controller;
  double curOffset = 0;
  double lastLetterOffset = 0;
  int textSelectionOffset = 0;
  UnixPtyC unixPtyC;
  @override
  void initState() {
    super.initState();
    final Size size = window.physicalSize;

    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.letterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.letterWidth;
    print('$this < row : $row column : $column>');
    controller = widget.controller ??
        TermareController(
          rowLength: row - 3,
          columnLength: column - 2,
        );
    unixPtyC = widget.unixPtyC ??
        UnixPtyC(
          libPath: Platform.isMacOS
              ? '/Users/nightmare/Desktop/termare-space/dart_pty/dynamic_library/libterm.dylib'
              : 'libterm.so',
          rowLen: row,
          columnLen: column - 2,
          environment: {
            'TERM': 'screen-256color',
            'PATH': '/data/data/com.nightmare/files/usr/bin:' +
                Platform.environment['PATH'],
          },
        );
    init();
  }

  Future<void> init() async {
    if (widget.autoFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
    while (mounted) {
      final String cur = unixPtyC.read();
      // print(('cur->$cur'));
      if (cur.isNotEmpty) {
        if (cur.contains('Audio')) {
          // print('等回去');
          print(cur);
        }
        controller.write(cur);
        controller.autoScroll = true;
        controller.notifyListeners();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        final String text = (await Clipboard.getData('text/plain')).text;
        unixPtyC.write(text);
      },
      child: TermareView(
        keyboardInput: (String data) {
          unixPtyC.write(data);
        },
        controller: controller,
      ),
    );
  }
}
