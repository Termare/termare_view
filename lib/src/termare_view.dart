import 'dart:io';
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
    this.bottomBar,
    this.onBell,
  }) : super(key: key);
  final TermareController controller;
  final KeyboardInput keyboardInput;
  final InputHandler onTextInput;
  final KeyStrokeHandler onKeyStroke;
  final ActionHandler onAction;
  final void Function() onBell;
  final Widget bottomBar;

  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  KeyboardHandler keyboardHandler;
  Size painterSize = const Size(0, 0);
  // 记录键盘高度
  double keyoardHeight = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.onBell = widget.onBell;
    WidgetsBinding.instance.addObserver(this);
    keyboardHandler = KeyboardHandler();
    widget.controller.addListener(updateTerm);
    testSequence();
    resizeWindow();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   resizeWindow();
  // }
  void updateTerm() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    resizeWindow();
  }

  void resizeWindow() {
    print('resizeWindow');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size size = window.physicalSize;
      final double screenWidth = size.width / window.devicePixelRatio;
      double screenHeight = size.height / window.devicePixelRatio;
      if (widget.bottomBar != null) {
        /// TODO
        screenHeight -= 32;
      }
      screenHeight -= MediaQuery.of(context).padding.top;
      keyoardHeight = MediaQuery.of(context).viewInsets.bottom;
      widget.controller.setPtyWindowSize(
        painterSize = Size(screenWidth, screenHeight - keyoardHeight),
      );
      if (keyoardHeight == 0) {
        // 键盘放下
        // print('键盘放下');
        if (widget.controller.cache.length > widget.controller.rowLength) {
          print(
              '当缓存的高度大于终端高度时 ${keyoardHeight ~/ widget.controller.theme.letterHeight}');
          // 当缓存的高度大于终端高度时
          widget.controller.startLine -= widget.controller.rowLength -
              1 -
              (widget.controller.cache.length - widget.controller.startLine);
        }
      }
      widget.controller.autoScroll = true;
      widget.controller.dirty = true;
      setState(() {});
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

    widget.controller.removeListener(updateTerm);
    super.dispose();
  }

  final initEditingState = const TextEditingValue(
    text: '  ',
    selection: TextSelection.collapsed(offset: 1),
  );
  TextEditingValue onTextEdit(
    TextEditingValue value,
  ) {
    if (value.text.length > initEditingState.text.length) {
      widget.keyboardInput(value.text.substring(1, value.text.length - 1));
    } else if (value.text.length < initEditingState.text.length) {
      widget.keyboardInput(String.fromCharCode(127));
    } else {
      if (value.selection.baseOffset < 1) {
        widget.keyboardInput(String.fromCharCode(2));
      } else if (value.selection.baseOffset > 1) {
        widget.keyboardInput(String.fromCharCode(6));
      }
    }

    return initEditingState;
  }

  @override
  Widget build(BuildContext context) {
    return InputListener(
      focusNode: _focusNode,
      onTextInput: (TextEditingValue value) {
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          return null;
        }
        //
        // print('onTextInput -> $value');
        return onTextEdit(
          value,
        );
      },
      onAction: (TextInputAction action) {
        print('onAction  ->  $action');
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          return null;
        }
        // 当软件盘回车按下的时候
        if (action == TextInputAction.done) {
          widget.keyboardInput('\n');
        }
        widget?.onAction(action);
      },
      onKeyStroke: (RawKeyEvent key) {
        print('onKeyStroke');
        // print(key);
        // 26键盘之外的按键按下的时候
        final String input = keyboardHandler.getKeyEvent(key);
        if (input != null) {
          widget.keyboardInput(input);
        }
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () async {
              // final String text = (await Clipboard.getData('text/plain')).text;
              // widget.keyboardInput?.call(text);
            },
            onTap: () {
              if (widget.keyboardInput != null) {
                InputListener.of(context).requestKeyboard();
              }
              print('按下');
            },
            child: ScrollViewTerm(
              controller: widget.controller,
              child: Stack(
                children: [
                  Material(
                    color: widget.controller.theme.backgroundColor,
                    child: SafeArea(
                      child: CustomPaint(
                        size: painterSize,
                        painter: TermarePainter(
                          controller: widget.controller,
                          color: const Color(0xff811016),
                        ),
                      ),
                    ),
                  ),
                  if (widget.bottomBar != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: keyoardHeight,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 32,
                          child: widget.bottomBar,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
