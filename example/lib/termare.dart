import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:termare/termare.dart';
import 'package:termare_pty/termare_pty.dart';

class Termare extends StatefulWidget {
  @override
  _TermareState createState() => _TermareState();
}

class _TermareState extends State<Termare> with WidgetsBindingObserver {
  TermareController controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final Size size = window.physicalSize;
    print('size->$size');
    print('window.devicePixelRatio->${window.devicePixelRatio}');
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight =
        size.height / window.devicePixelRatio - kToolbarHeight;

    controller = TermareController();
    controller.setPtyWindowSize(Size(screenWidth, screenHeight));
    // window.onMetricsChanged = () {
    //   print('window.onMetricsChanged');
    // };
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size size = window.physicalSize;
      final double screenWidth = size.width / window.devicePixelRatio;
      final double screenHeight = size.height / window.devicePixelRatio -
          MediaQuery.of(context).padding.top;
      final double keyoardHeight = MediaQuery.of(context).viewInsets.bottom;
      print('kToolbarHeight->${MediaQuery.of(context).viewInsets.top}');
      print('kToolbarHeight->${MediaQuery.of(context).padding.top}');
      // SafeArea()
      print(
        ' ${Size(screenWidth, screenHeight - keyoardHeight)}',
      );
      controller.setPtyWindowSize(
        Size(screenWidth, screenHeight - keyoardHeight),
      );
      controller.autoScroll = true;
      controller.dirty = true;
      controller.notifyListeners();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
