import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare/src/termare_controller.dart';

import 'painter/termare_painter.dart';
import 'utils/keyboard_handler.dart';

class TermareView extends StatefulWidget {
  const TermareView({Key key, this.controller, this.keyboardInput})
      : super(key: key);
  final TermareController controller;
  final KeyboardInput keyboardInput;

  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView>
    with TickerProviderStateMixin {
  double curOffset = 0;
  FocusNode focusNode = FocusNode();
  AnimationController animationController;

  KeyboardHandler keyboardHandler;
  @override
  void initState() {
    super.initState();
    keyboardHandler = KeyboardHandler(widget.keyboardInput);
    SystemChannels.keyEvent.setMessageHandler(keyboardHandler.handleKeyEvent);
    widget.controller.addListener(() {
      setState(() {});
    });
    testSequence();
  }

  Future<void> testSequence() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    );
    File
    // SequencesTest.testMang(controller);
    // SequencesTest.testIsOut(controller);
    // SequencesTest.testColorText(controller);
    widget.controller.dirty = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      },
      onPanDown: (details) {},
      // onVerticalDragUpdate: (details) {
      //   print(details.delta);
      // },
      onPanUpdate: (details) {
        widget.controller.autoScroll = false;
        widget.controller.dirty = true;
        if (details.delta.dy > 0) {
          if (curOffset > 0) {
            curOffset = 0;
            return;
          }
          curOffset += details.delta.dy;
          print('往下滑动');
        }
        if (details.delta.dy < 0) {
          final int outLine = -curOffset.toInt() ~/
              widget.controller.theme.letterHeight.toInt();
          if (widget.controller.currentPointer.dy - outLine <
              widget.controller.rowLength) {
            return;
          }
          curOffset += details.delta.dy;
          print('controller${widget.controller.currentPointer.dy - outLine}');
          print('往上滑动');
        }
        print(
          'curOffset->$curOffset  details.delta.dy->${details.delta.dy}  details.globalPosition->${details.globalPosition}',
        );
        setState(() {});
      },
      onPanEnd: (details) {
        final double pixelsPerSecondDy = details.velocity.pixelsPerSecond.dy;
        // return;
        widget.controller.dirty = true;
        final double velocity =
            1.0 / (0.050 * WidgetsBinding.instance.window.devicePixelRatio);
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

          // if (pixelsPerSecondDy > 0) {
          //   if (shouldOffset > 0) {
          //     curOffset = 0;
          //   } else {
          //     curOffset = shouldOffset;
          //   }
          // }
          // print('curOffset------------>$curOffset');
          curOffset = shouldOffset;
          if (pixelsPerSecondDy > 0) {
            final int outLine = -curOffset.toInt() ~/
                widget.controller.theme.letterHeight.toInt();
            if (widget.controller.currentPointer.dy - outLine <
                widget.controller.rowLength) {
              return;
            }
            curOffset = shouldOffset;
          }

          if (curOffset > 0) {
            curOffset = 0;
          }
          setState(() {});
          // final int outLine =
          //     -curOffset.toInt() ~/ controller.theme.letterHeight.toInt();
          // if (controller.currentPointer.dy - outLine < controller.rowLength) {
          //   return;
          // }
        });
        animationController.animateWith(clampingScrollSimulation);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: 200,
                child: Builder(
                  builder: (_) {
                    // print(
                    //     'MediaQuery.of(context).viewInsets.bottom->${MediaQuery.of(context).viewPadding.bottom}');

                    // print('col:$column');
                    // print('row:$row');
                    return CustomPaint(
                      painter: TermarePainter(
                        controller: widget.controller,
                        rowLength: widget.controller.rowLength,
                        columnLength: widget.controller.columnLength,
                        defaultOffsetY: curOffset,
                        lastLetterPositionCall: (lastLetterOffset) async {
                          // this.lastLetterOffset = lastLetterOffset;
                          print('lastLetterOffset : $lastLetterOffset');
                          curOffset += lastLetterOffset;
                          // if (!scrollLock && lastLetterOffset > 0) {
                          //   scrollLock = true;
                          //   await Future<void>.delayed(
                          //     const Duration(milliseconds: 100),
                          //   );
                          //   curOffset -= lastLetterOffset;
                          //   setState(() {});
                          //   scrollLock = false;
                          // }
                        },
                        color: const Color(0xff811016),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
