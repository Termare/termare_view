import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:dart_pty/dart_pty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'painter/termare_painter.dart';
import 'termare_controller.dart';
import 'unix/term.dart';
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

    // termareController.write(
    //     "echo 'abc h\x08ello H\x8ello from \\033[1;3;31mxterm.js\\033[0m \$ Hello from \x1B[1;3;31mxterm.js\x1B[0m \$' \n");
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

  // @override
  // void didUpdateWidget(RotatedView oldWidget) {
  //   WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
  //   super.didUpdateWidget(oldWidget);
  // }

  void _onAfterRendering(Duration timeStamp) {
    print('$this 刷新 ${MediaQuery.of(context).viewInsets}');
    // double screenWidth = MediaQuery.of(context).size.width;
    // int column = screenWidth ~/ 11.0;
    // print('column-$column');
    // print('MediaQuery.of(context).size.width->$screenWidth');
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
    // DynamicLibrary dynamicLibrary = DynamicLibrary.open(
    //     '/Users/nightmare/Desktop/termare/new_term/c_resource/NiTerm/src/build/libterm.dylib');
    // int ptm = unixPty.createPseudoTerminal(
    //   verbose: true,
    // );
    // unixPty.createSubprocess(ptm);
    // unixPty.setNonblock(
    //   ptm,
    //   verbose: true,
    // );
    // //     final Pointer<Uint8> resultPoint = fileDescriptor.read();
    // read(ptm);
    // // 代表空指针
    // if (resultPoint.address == 0) {
    //   // 释放内存
    //   // free(resultPoint);
    //   return '';
    // }
    // String result = _niUtf.cStringtoString(resultPoint);
  }

  @override
  Widget build(BuildContext context) {
    // print("codeUnits->${'a'.codeUnits}");
    return GestureDetector(
      onTap: () {
        // // SystemChannels.textInput.invokeMethod('TextInput.hide');
        scrollLock = false;
        focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
        // setState(() {});
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
        // if (lastLetterOffset < 0) {
        //   curOffset -= lastLetterOffset;
        //   return;
        // }
        double shouldOffset =
            preOffset + (details.globalPosition.dy - onPanDownOffset);
        // if (curOffset < 0) {
        //   if (lastLetterOffset < 0 && shouldOffset < curOffset) {
        //     return;
        //   }
        // }
        curOffset = shouldOffset;
        if (curOffset > 0) curOffset = 0;
        print('curOffset->$curOffset');
        setState(() {});
      },
      onPanEnd: (details) {
        scrollLock = true;
        final Tolerance tolerance = Tolerance(
          velocity: 1.0 /
              (0.050 *
                  WidgetsBinding.instance.window
                      .devicePixelRatio), // logical pixels per second
          distance: 1.0 /
              WidgetsBinding.instance.window.devicePixelRatio, // logical pixels
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
          if (curOffset < 0) {
            if (lastLetterOffset < 0 && shouldOffset < curOffset) {
              return;
            }
          }
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

              // Align(
              //   alignment: Alignment.center,
              //   child: SingleChildScrollView(
              //     child: SizedBox(
              //       height: 100,
              //       child: TextField(
              //         style: TextStyle(color: Colors.white),
              //         controller: _editingController,
              //         autofocus: false,
              //         keyboardType: TextInputType.text,
              //         focusNode: focusNode,
              //         // style: const TextStyle(color: Colors.transparent),
              //         // cursorColor: Colors.transparent,
              //         showCursor: false,
              //         cursorWidth: 20,
              //         enabled: true,
              //         scrollPadding: const EdgeInsets.all(0.0),
              //         enableInteractiveSelection: false,
              //         decoration: InputDecoration(
              //           alignLabelWithHint: true,
              //           // border: InputBorder.none,
              //           // hasFloatingPlaceholder: false,
              //         ),
              //         onChanged: (String strCall) {
              //           String currentInput;

              //           // print(
              //           //     'editingController.selection.end===>${editingController.selection.end}');
              //           // print('currentInput===>$currentInput');
              //           // print(textSelectionOffset);
              //           if (_editingController.selection.end >
              //               textSelectionOffset) {
              //             currentInput =
              //                 strCall[_editingController.selection.end - 1];
              //             // if (isUseCtrl) {
              //             //   _nitermController.write(String.fromCharCode(
              //             //       currentInput.toUpperCase().codeUnits[0] - 64));
              //             //   isUseCtrl = false;
              //             //   setState(() {});
              //             // } else {
              //             termareController.write(currentInput);
              //             // }
              //           } else {
              //             termareController.write(utf8.decode(<int>[127]));
              //           }
              //           textSelectionOffset = _editingController.selection.end;
              //         },
              //         onEditingComplete: () {
              //           textSelectionOffset = 0;
              //         },
              //         onSubmitted: (String a) {
              //           _editingController.clear();
              //           termareController.write('\n');
              //         },
              //       ),
              //     ),
              //   ),
              // ),
              // TextField(
              //   focusNode: focusNode,
              //   onChanged: (str) {
              //     print(str);
              //     // unixPty.write(unixPthC.pseudoTerminalId, str);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
