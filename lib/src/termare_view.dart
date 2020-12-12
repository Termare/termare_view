import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/src/widget/input_listener.dart';
import 'package:termare_view/src/termare_controller.dart';

import 'painter/termare_painter.dart';
import 'utils/keyboard_handler.dart';
import 'widget/scroll_view.dart';

class TermareView extends StatefulWidget {
  const TermareView({
    Key key,
    this.controller,
    this.keyboardInput,
    this.onTextInput,
    this.onKeyStroke,
    this.onAction,
  }) : super(key: key);
  final TermareController controller;
  final KeyboardInput keyboardInput;
  final InputHandler onTextInput;
  final KeyStrokeHandler onKeyStroke;
  final ActionHandler onAction;

  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  KeyboardHandler keyboardHandler;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    keyboardHandler = KeyboardHandler(widget.keyboardInput);
    widget.controller.addListener(() {
      setState(() {});
    });
    testSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resizeWindow();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    resizeWindow();
  }

  void resizeWindow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size size = window.physicalSize;
      final double screenWidth = size.width / window.devicePixelRatio;
      final double screenHeight = size.height / window.devicePixelRatio -
          MediaQuery.of(context).padding.top;
      final double keyoardHeight = MediaQuery.of(context).viewInsets.bottom;
      // print('kToolbarHeight->${MediaQuery.of(context).viewInsets.top}');
      // print(
      //     'MediaQuery.of(context).padding.top->${MediaQuery.of(context).padding.top}');
      // // SafeArea()
      // print(
      //   ' ${Size(screenWidth, screenHeight - keyoardHeight)}',
      // );
      // print('keyoardHeight->${MediaQuery.of(context).viewInsets.bottom}');
      // print('keyoardHeight->${MediaQuery.of(context).padding.bottom}');
      widget.controller.setPtyWindowSize(
        Size(screenWidth, screenHeight - keyoardHeight),
      );
      if (keyoardHeight == 0) {
        if (widget.controller.cache.length > widget.controller.rowLength) {
          widget.controller.startLine -=
              widget.controller.cache.length - widget.controller.startLine - 1;
        }
        // print('------${widget.controller.cache.length - widget.controller.startLine}');
        // controller.startLine=controller.startLine-;
      }
      widget.controller.autoScroll = true;
      widget.controller.dirty = true;
      widget.controller.notifyListeners();
    });
  }

  Future<void> testSequence() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    );
    // SequencesTest.testMang(controller);
    // SequencesTest.testIsOut(widget.controller);
    // SequencesTest.testColorText(controller);
    widget.controller.dirty = true;
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputListener(
      focusNode: _focusNode,
      onTextInput: (TextEditingValue value) {
        //
        // print('onTextInput -> $value');
        widget.keyboardInput(value.text.substring(1, value.text.length - 1));
        return const TextEditingValue(
          text: '  ',
          selection: TextSelection.collapsed(offset: 1),
        );
      },
      onAction: (TextInputAction action) {
        // 当软件盘回车按下的时候
        if (action == TextInputAction.done) {
          widget.keyboardInput('\n');
        }
        widget.onAction(action);
      },
      onKeyStroke: (RawKeyEvent key) {
        // 26键盘之外的按键按下的时候
        keyboardHandler.handleKeyEvent(key);
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () async {
              final String text = (await Clipboard.getData('text/plain')).text;
              widget.keyboardInput(text);
            },
            onTap: () {
              InputListener.of(context).requestKeyboard();
              print('按下');
            },
            child: ScrollViewTerm(
              controller: widget.controller,
              child: Scaffold(
                backgroundColor: Colors.black,
                body: SafeArea(
                  child: CustomPaint(
                    painter: TermarePainter(
                      controller: widget.controller,
                      color: const Color(0xff811016),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
