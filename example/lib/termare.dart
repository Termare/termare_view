import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:termare/termare.dart';
import 'package:termare_pty/termare_pty.dart';

class Termare extends StatefulWidget {
  @override
  _TermareState createState() => _TermareState();
}

class _TermareState extends State<Termare> {
  TermareController controller;
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
      rowLength: row - 3,
      columnLength: column - 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Material(
        textStyle: TextStyle(
          color: Colors.white,
        ),
        color: Colors.grey.withOpacity(0.2),
        child: SizedBox(
          width: 200,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Column(
              children: [
                const Text('字体大小'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        controller.setFontSize(controller.theme.fontSize - 1);
                        setState(() {});
                      },
                    ),
                    Text(controller.theme.fontSize.toString()),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        controller.setFontSize(controller.theme.fontSize + 1);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('显示网格'),
                    Checkbox(
                      value: controller.showLine,
                      onChanged: (value) {
                        controller.showLine = value;
                        controller.dirty = true;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: TermarePty(
        controller: controller,
      ),
    );
  }
}
