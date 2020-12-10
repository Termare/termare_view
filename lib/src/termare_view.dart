import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare/src/input/input_listener.dart';
import 'package:termare/src/termare_controller.dart';

import 'painter/termare_painter.dart';
import 'utils/keyboard_handler.dart';

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

class _TermareViewState extends State<TermareView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  double curOffset = 0;
  AnimationController animationController;
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
  void didChangeMetrics() {
    super.didChangeMetrics();
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
    print('_focusNode.dispose()');
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
            onPanDown: (details) {
              print('按下');
              curOffset = -widget.controller.startLine *
                  widget.controller.theme.letterHeight;
            },
            onPanUpdate: (details) {
              widget.controller.autoScroll = false;
              widget.controller.dirty = true;
              if (details.delta.dy > 0) {
                // 往下滑动

                curOffset += details.delta.dy;
                if (curOffset > 0) {
                  curOffset = 0;
                  return;
                }
                final int outLine = -curOffset.toInt() ~/
                    widget.controller.theme.letterHeight.toInt();
                widget.controller.startLine = outLine;
              }
              if (details.delta.dy < 0) {
                // 往上滑动
                // TODO
                // 当内容还没有满一个终端高度的时候
                if (widget.controller.cache.length >
                    widget.controller.rowLength) {
                  curOffset += details.delta.dy;

                  int outLine = -curOffset ~/
                      widget.controller.theme.letterHeight.toInt();
                  if (outLine + widget.controller.rowLength - 1 >
                      widget.controller.cache.length) {
                    outLine = widget.controller.cache.length -
                        widget.controller.rowLength +
                        1;
                    curOffset = -outLine * widget.controller.theme.letterHeight;
                  }
                  widget.controller.startLine = outLine;
                }

                // PrintUtil.printD(
                //     'outLine->${widget.controller.startLine} ${widget.controller.cache.length} ${widget.controller.rowLength} ',
                //     [31]);
                // print('controller${widget.controller.currentPointer.dy - outLine}');

              }

              setState(() {});
            },
            onPanEnd: (details) {
              final double pixelsPerSecondDy =
                  details.velocity.pixelsPerSecond.dy;
              // return;
              widget.controller.dirty = true;
              final double velocity = 1.0 /
                  (0.050 * WidgetsBinding.instance.window.devicePixelRatio);
              final double distance =
                  1.0 / WidgetsBinding.instance.window.devicePixelRatio;
              final Tolerance tolerance = Tolerance(
                velocity: velocity, // logical pixels per second
                distance: distance, // logical pixels
              );
              final double start = curOffset;
              final ClampingScrollSimulation clampingScrollSimulation =
                  ClampingScrollSimulation(
                position: start,
                velocity: details.velocity.pixelsPerSecond.dy,
                tolerance: tolerance,
              );
              animationController = AnimationController(
                vsync: this,
                value: 0,
                lowerBound: double.negativeInfinity,
                upperBound: double.infinity,
              );
              animationController.reset();
              animationController.addListener(() {
                final double shouldOffset = animationController.value;
                widget.controller.dirty = true;
                // print('shouldOffset->$shouldOffset');
                if (pixelsPerSecondDy > 0) {
                  // 往下滑动

                  curOffset = shouldOffset;
                  if (curOffset > 0) {
                    curOffset = 0;
                    animationController.stop();
                  }
                  final int outLine =
                      -curOffset ~/ widget.controller.theme.letterHeight;
                  widget.controller.startLine = outLine;
                }
                if (pixelsPerSecondDy < 0) {
                  if (widget.controller.cache.length >
                      widget.controller.rowLength) {
                    curOffset = shouldOffset;

                    int outLine =
                        -curOffset ~/ widget.controller.theme.letterHeight;
                    if (outLine + widget.controller.rowLength - 1 >
                        widget.controller.cache.length) {
                      // 做多往上滑动到输入光标上一个格子
                      outLine = widget.controller.cache.length -
                          widget.controller.rowLength +
                          1;
                      curOffset =
                          -outLine * widget.controller.theme.letterHeight;
                      animationController.stop();
                    }
                    widget.controller.startLine = outLine;
                  }

                  // PrintUtil.printD(
                  //     'outLine->${widget.controller.startLine} ${widget.controller.cache.length} ${widget.controller.rowLength} ',
                  //     [31]);
                  // print('controller${widget.controller.currentPointer.dy - outLine}');

                }

                setState(() {});
              });
              animationController.animateWith(clampingScrollSimulation);
            },
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
          );
        },
      ),
    );
  }
}
