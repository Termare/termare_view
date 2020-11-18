import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'painter/termare_painter.dart';
import 'termare_controller.dart';
import 'utils/keyboard_handler.dart';

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
  TermareController termareController;
  double preOffset = 0;
  double onPanDownOffset = 0;
  double curOffset = 0;
  double lastLetterOffset = 0;
  KeyboardHandler keyboardHandler;
  @override
  void initState() {
    super.initState();
    termareController = widget.controller ??
        TermareController(
          environment: {
            'TERM': 'screen-256color',
            'abc': 'def',
            'PATH': '/data/data/com.nightmare/files/usr/bin:' +
                Platform.environment['PATH'],
          },
        );
    keyboardHandler = KeyboardHandler(termareController);
    animationController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    init();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  void _onAfterRendering(Duration timeStamp) {
    print('$this 刷新 ${MediaQuery.of(context).viewInsets}');
  }

  int textSelectionOffset = 0;
  FocusNode focusNode = FocusNode();
  TextEditingController _editingController = TextEditingController();
  bool scrollLock = false;

  Future<void> init() async {
//     await termareController.defineTermFunc('''
//     function test(){
// for i in \$(seq 1 100)
// do
// echo \$i;
// sleep 0.1
// done
//   }
//     ''');
    // termareController.write('test\n');
    SystemChannels.keyEvent.setMessageHandler(keyboardHandler.handleKeyEvent);
    if (widget.autoFocus) {
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
    // focusNode.attach(context);
    // focusNode.requestFocus();
    // focusNode.onKey;
    // focusNode.onKey=(a){};
    // unixPthC.write('python3\n');
    while (mounted) {
      String cur = termareController.read();
      // print(('cur->$cur'));
      if (cur.isNotEmpty) {
        termareController.out += cur;
        termareController.notifyListeners();
        termareController.dirty = true;
        scrollLock = false;
        setState(() {});
        // await Future.delayed(Duration(milliseconds: 10));
      } else {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        scrollLock = false;
        focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
      onDoubleTap: () async {
        final String text = (await Clipboard.getData('text/plain')).text;
        termareController.write(text);
      },
      onPanDown: (details) {
        scrollLock = true;
        onPanDownOffset = details.globalPosition.dy;
        preOffset = curOffset;
      },
      onPanUpdate: (details) {
        scrollLock = true;

        double shouldOffset =
            preOffset + (details.globalPosition.dy - onPanDownOffset);
        curOffset = shouldOffset;
        if (curOffset > 0) curOffset = 0;
        print('curOffset->$curOffset');
        setState(() {});
      },
      onPanEnd: (details) {
        scrollLock = true;
        double velocity =
            1.0 / (0.050 * WidgetsBinding.instance.window.devicePixelRatio);
        double distance = 1.0 / WidgetsBinding.instance.window.devicePixelRatio;
        final Tolerance tolerance = Tolerance(
          velocity: velocity, // logical pixels per second
          distance: distance, // logical pixels
        );
        double start = curOffset;
        ClampingScrollSimulation clampingScrollSimulation =
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
          double shouldOffset = animationController.value;
          // print(object)
          // if (curOffset < 0) {
          //   if (lastLetterOffset < 0 && shouldOffset < curOffset) {
          //     return;
          //   }
          // }
          curOffset = shouldOffset;
          if (curOffset > 0) curOffset = 0;
          print('curOffset->$curOffset');
          setState(() {});
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
                    print(
                        'MediaQuery.of(context).viewInsets.bottom->${MediaQuery.of(context).viewPadding.bottom}');
                    Size size = MediaQuery.of(context).size;
                    double screenWidth = size.width;
                    double screenHeight =
                        size.height - MediaQuery.of(context).viewInsets.bottom;
                    // 行数
                    int row = screenHeight ~/ 16.0;
                    // 列数
                    int column = screenWidth ~/ 8.0;
                    // print('col:$column');
                    // print('row:$row');
                    return CustomPaint(
                      painter: TermarePainter(
                        controller: termareController,
                        theme: termareController.theme,
                        rowLength: (row - 4),
                        columnLength: column - 2,
                        defaultOffsetY: curOffset,
                        lastLetterPositionCall: (lastLetterOffset) async {
                          this.lastLetterOffset = lastLetterOffset;
                          print('lastLetterOffset : $lastLetterOffset');
                          if (!scrollLock && lastLetterOffset > 0) {
                            scrollLock = true;
                            await Future.delayed(Duration(milliseconds: 100));

                            curOffset -= lastLetterOffset;
                            setState(() {});
                            scrollLock = false;
                          }
                        },
                        color: const Color(0xff811016),
                        input: termareController.out,
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
