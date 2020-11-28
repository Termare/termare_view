import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'painter/termare_painter.dart';
import 'termare_controller.dart';
import 'utils/keyboard_handler.dart';
import 'utils/sequences_test.dart';

class TermareView extends StatefulWidget {
  const TermareView({
    Key key,
    this.controller,
    this.autoFocus = false,
  }) : super(key: key);
  final TermareController controller;
  final bool autoFocus;
  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  TermareController controller;
  double curOffset = 0;
  double lastLetterOffset = 0;
  KeyboardHandler keyboardHandler;
  int textSelectionOffset = 0;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        TermareController(
          environment: {
            'TERM': 'screen-256color',
            'abc': 'def',
            'PATH': '/data/data/com.nightmare/files/usr/bin:' +
                Platform.environment['PATH'],
          },
        );

    keyboardHandler = KeyboardHandler(controller.unixPthC);
    animationController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    init();
    testSequence();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  void _onAfterRendering(Duration timeStamp) {
    print('$this 刷新 ${MediaQuery.of(context).viewInsets}');
  }

  Future<void> testSequence() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    );
    // SequencesTest.testMang(controller);
    // SequencesTest.testIsOut(controller);
    // SequencesTest.testColorText(controller);
    controller.dirty = true;
    setState(() {});
  }

  Future<void> init() async {
    SystemChannels.keyEvent.setMessageHandler(keyboardHandler.handleKeyEvent);
    if (widget.autoFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
    controller.addListener(() {
      setState(() {});
    });
    while (mounted) {
      final String cur = controller.read();
      // print(('cur->$cur'));
      if (cur.isNotEmpty) {
        controller.currentRead = cur;
        if (cur.contains('Audio')) {
          // print('等回去');
          print(cur);
        }
        controller.write(cur);
        controller.autoScroll = true;
        controller.dirty = true;
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
      onTap: () {
        // controller.write('啊');
        // termareController.out += utf8.decode([
        //   27,
        //   91,
        //   63,
        //   50,
        //   53,
        //   108,
        //   32,
        //   32,
        //   68,
        //   111,
        //   119,
        //   110,
        //   108,
        //   111,
        //   97,
        //   100,
        //   105,
        //   110,
        //   103,
        //   32,
        //   104,
        //   116,
        //   116,
        //   112,
        //   115,
        //   58,
        //   47,
        //   47,
        //   109,
        //   105,
        //   114,
        //   114,
        //   111,
        //   114,
        //   46,
        //   98,
        //   97,
        //   105,
        //   100,
        //   117,
        //   46,
        //   99,
        //   111,
        //   109,
        //   47,
        //   112,
        //   121,
        //   112,
        //   105,
        //   47,
        //   112,
        //   97,
        //   99,
        //   107,
        //   97,
        //   103,
        //   101,
        //   115,
        //   47,
        //   51,
        //   48,
        //   47,
        //   52,
        //   54,
        //   47,
        //   56,
        //   50,
        //   49,
        //   57,
        //   50,
        //   48,
        //   57,
        //   56,
        //   54,
        //   99,
        //   55,
        //   99,
        //   101,
        //   53,
        //   98,
        //   97,
        //   101,
        //   53,
        //   53,
        //   49,
        //   56,
        //   99,
        //   49,
        //   100,
        //   52,
        //   57,
        //   48,
        //   101,
        //   53,
        //   50,
        //   48,
        //   97,
        //   57,
        //   97,
        //   98,
        //   52,
        //   99,
        //   101,
        //   102,
        //   53,
        //   49,
        //   101,
        //   51,
        //   101,
        //   53,
        //   52,
        //   101,
        //   51,
        //   53,
        //   48,
        //   57,
        //   52,
        //   100,
        //   97,
        //   100,
        //   102,
        //   48,
        //   100,
        //   54,
        //   56,
        //   47,
        //   111,
        //   112,
        //   101,
        //   110,
        //   99,
        //   118,
        //   45,
        //   112,
        //   121,
        //   116,
        //   104,
        //   111,
        //   110,
        //   45,
        //   52,
        //   46,
        //   52,
        //   46,
        //   48,
        //   46,
        //   52,
        //   54,
        //   46,
        //   116,
        //   97,
        //   114,
        //   46,
        //   103,
        //   122,
        //   32,
        //   40,
        //   56,
        //   56,
        //   46,
        //   57,
        //   77,
        //   66,
        //   41,
        //   13
        // ]);
        focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      },
      onDoubleTap: () async {
        final String text = (await Clipboard.getData('text/plain')).text;
        controller.unixPthC.write(text);
      },
      onPanDown: (details) {},
      // onVerticalDragUpdate: (details) {
      //   print(details.delta);
      // },
      onPanUpdate: (details) {
        controller.autoScroll = false;
        controller.dirty = true;
        if (details.delta.dy > 0) {
          if (curOffset > 0) {
            curOffset = 0;
            return;
          }
          curOffset += details.delta.dy;
          print('往下滑动');
        }
        if (details.delta.dy < 0) {
          final int outLine =
              -curOffset.toInt() ~/ controller.theme.letterHeight.toInt();
          if (controller.currentPointer.dy - outLine < controller.rowLength) {
            return;
          }
          curOffset += details.delta.dy;
          print('controller${controller.currentPointer.dy - outLine}');
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
        controller.dirty = true;
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
          controller.dirty = true;

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
            final int outLine =
                -curOffset.toInt() ~/ controller.theme.letterHeight.toInt();
            if (controller.currentPointer.dy - outLine < controller.rowLength) {
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
                    final Size size = MediaQuery.of(context).size;
                    final double screenWidth = size.width;
                    final double screenHeight =
                        size.height - MediaQuery.of(context).viewInsets.bottom;
                    // 行数
                    final int row =
                        screenHeight ~/ controller.theme.letterHeight;
                    // 列数
                    final int column =
                        screenWidth ~/ controller.theme.letterWidth;
                    // print('col:$column');
                    // print('row:$row');
                    return CustomPaint(
                      painter: TermarePainter(
                        controller: controller,
                        rowLength: row - 3,
                        columnLength: column - 2,
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
