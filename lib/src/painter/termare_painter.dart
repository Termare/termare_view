import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare/src/config/cache.dart';
import 'package:termare/src/painter/model/position.dart';
import 'package:termare/src/termare_controller.dart';

TextLayoutCache cache = TextLayoutCache(TextDirection.ltr, 4096);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
    this.rowLength,
    this.columnLength,
    this.defaultOffsetY,
    this.color = Colors.white,
    this.input,
    this.lastLetterPositionCall,
  }) {
    termWidth = columnLength * controller.theme.letterWidth;
    termHeight = rowLength * controller.theme.letterHeight;
    defaultStyle = TextStyle(
      textBaseline: TextBaseline.ideographic,
      height: 1,
      fontSize: controller.theme.letterHeight - 2,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      // backgroundColor: Colors.black,
      // backgroundColor: Colors.red,
      fontFamily: 'monospace',
    );
  }
  final TermareController controller;
  final int rowLength;
  final int columnLength;
  double termWidth;
  double termHeight;
  int curPaintIndex = 0;
  // // 这个 bool 值用得很烂，用来内层循环跳出外层循环
  // bool isOutLine = false;
  List<Color> colors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.brown,
    Colors.cyan,
  ];
  final Color color;
  final double defaultOffsetY;
  final void Function(double lastLetterPosition) lastLetterPositionCall;
  double padding;
  final String input;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
  Position _position = Position(0, 0);

  final Stopwatch stopwatch = Stopwatch();
  TextStyle defaultStyle;
  void drawLine(Canvas canvas) {
    final Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Colors.grey.withOpacity(0.4);
    for (int j = 0; j <= rowLength; j++) {
      // print(j);
      canvas.drawLine(
        Offset(
          0,
          j * controller.theme.letterHeight,
        ),
        Offset(
          termWidth,
          j * controller.theme.letterHeight,
        ),
        paint,
      );
    }
    for (int k = 0; k <= columnLength; k++) {
      canvas.drawLine(
        Offset(
          k * controller.theme.letterWidth,
          0,
        ),
        Offset(k * controller.theme.letterWidth, termHeight),
        paint,
      );
    }
  }

  void drawBackground(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, termWidth, termHeight),
      Paint()..color = Colors.black,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    PrintUtil.printd(
      '${'>' * 32} $this defaultOffsetY->$defaultOffsetY',
      32,
    );
    final int outLine =
        defaultOffsetY.toInt() ~/ controller.theme.letterHeight.toInt();
    PrintUtil.printd(
      '$this defaultOffsetY->$defaultOffsetY  outLine->$outLine  defaultOffsetY.toInt()->${defaultOffsetY.toInt()}',
      31,
    );

    PrintUtil.printD('stopwatch -> ${stopwatch.elapsed}', [31, 47, 7]);
    _position = Position(0, 0);
    curPaintIndex = 0;
    drawBackground(canvas);
    PrintUtil.printD('stopwatch -> ${stopwatch.elapsed}', [31, 47, 7]);
    // print('_position->$_position');
    final List<String> outList = input.split('\n');
    PrintUtil.printD('stopwatch -> ${stopwatch.elapsed}', [31, 47, 7]);
    PrintUtil.printd(
      '${'>' * 32} input  ',
      32,
    );
    print(input);
    PrintUtil.printd(
      '${'<' * 32} ',
      32,
    );
    PrintUtil.printD('stopwatch -> ${stopwatch.elapsed}', [31, 47, 7]);
    TextStyle curStyle = defaultStyle;
    for (int j = -outLine; j < outList.length; j++) {
      final String line = outList[j];
      if (line.contains('|')) {
        print('wait');
        for (final int char in line.codeUnits) {
          PrintUtil.printd('char->$char', 34);
        }
      }
      PrintUtil.printd('line->$line', 35);
      PrintUtil.printd('line.codeUnits->${line.codeUnits}', 35);
      // continue;s
      for (int i = 0; i < line.length; i++) {
        final List<int> codeUnits = line[i].codeUnits;
        // PrintUtil.printD(
        //     'utf8.encode start -> ${stopwatch.elapsed}', [31, 47, 7]);
        // PrintUtil.printD(
        //     'utf8.encode end -> ${stopwatch.elapsed}', [31, 47, 7]);
        if (codeUnits.length == 1) {
          // 说明单字节
          if (eq(codeUnits, [0x07])) {
            PrintUtil.printn('<- C0 Bell ->', 31, 47);
            continue;
          }
          if (eq(codeUnits, [0x08])) {
            // 光标左移动
            PrintUtil.printn('<- C0 Backspace ->', 31, 47);
            final RegExp doubleByteReg = RegExp('[^\x00-\xff]');
            final bool isDoubleByte = doubleByteReg.hasMatch(line[i - 1]);
            if (isDoubleByte) {
              // print('双字节字符---->${line[i]}');
              moveToNextOffset(-1);
            }
            moveToNextOffset(-1);
            continue;
          }

          if (eq(codeUnits, [0x09])) {
            moveToNextOffset(4);

            PrintUtil.printn('<- C0 Horizontal Tabulation ->', 31, 47);
            // print('<- Horizontal Tabulation ->');
            continue;
          }
          if (eq(codeUnits, [0x0a]) ||
              eq(codeUnits, [0x0b]) ||
              eq(codeUnits, [0x0c])) {
            moveNewLineOffset();
            PrintUtil.printn('<- C0 Line Feed ->', 31, 47);
            continue;
          }
          if (eq(codeUnits, [0x0d])) {
            // ascii 13
            moveToLineFirstOffset();
            PrintUtil.printn('<- C0 Carriage Return ->', 31, 47);
            continue;
          }

          if (eq(line[i].codeUnits, [0x1b])) {
            // print('<- ESC ->');
            i += 1;
            final String curStr = line[i];
            PrintUtil.printd('preStr-> ESC curStr->$curStr', 31);
            switch (curStr) {
              case '[':
                i += 1;
                final String curStr = line[i];
                print(line.substring(i));
                PrintUtil.printd(
                  'preStr-> \x1b[32;7m[\x1b[31m ->curStr-> \x1b[32m$curStr\x1b[31m',
                  31,
                );
                switch (curStr) {
                  // 27 91 75
                  case 'K':
                    // i += 1;
                    // print(line[i - 5]);

                    // TODO 这个是删除的序列，写得有问题
                    // bool isDoubleByte = doubleByteReg.hasMatch(line[i - 5]);
                    // if (isDoubleByte) {
                    //   // print('数按字节字符---->${line[i]}');
                    // }
                    canvas.drawRect(
                      Rect.fromLTWH(
                        _position.dx * controller.theme.letterWidth,
                        _position.dy * controller.theme.letterHeight +
                            defaultOffsetY,
                        false
                            ? 2 * controller.theme.letterWidth
                            : controller.theme.letterWidth,
                        controller.theme.letterHeight,
                      ),
                      Paint()..color = Colors.black,
                    );
                    continue;
                    break;
                  case '?':
                    i += 1;
                    final RegExp regExp = RegExp('l');
                    final int w = line.substring(i + 1).indexOf(regExp);
                    final String number = line.substring(i, i + w);
                    if (number == '25') {
                      i += 2;
                      controller.showCursor = false;
                    }
                    i += 1;
                    PrintUtil.printd('[ ? 后的值->${line.substring(i)}', 31);
                    continue;
                    break;
                  default:
                }
                print('line.substring(i + 1)->${line.substring(i)}');
                final int charMindex = line.substring(i).indexOf('m');

                print('charMindex=======>$charMindex');
                String header = '';
                header = line.substring(i, i + charMindex);
                print('header->$header');
                header.split(';').forEach((element) {
                  curStyle = getTextStyle(element, curStyle);
                });
                i += header.length;
                break;
              default:
            }

            continue;
          }

          /// ------------------ c0 ----------------------
        }
        if (isOutTerm()) {
          if (controller.autoScroll) {
            PrintUtil.printd(
                'line 越界 -> ${line}  $j  ${outList.length}  ${outList.length - j}',
                31);
            lastLetterPositionCall(
                -controller.theme.letterHeight * (outList.length - j));
          }
          PrintUtil.printd('line[i] 越界 -> ${line[i]}', 31);
          j = outList.length;
          break;
        } // TODO 可能会数组越界
        final bool isDoubleByte = codeUnits.first > 0x7f;
        canvas.drawRect(
          Rect.fromLTWH(
            _position.dx * controller.theme.letterWidth,
            _position.dy * controller.theme.letterHeight,
            isDoubleByte
                ? 2 * controller.theme.letterWidth
                : controller.theme.letterWidth,
            controller.theme.letterHeight,
          ),
          Paint()..color = Colors.black,
        );
        final TextPainter painter = cache.getOrPerformLayout(
          TextSpan(
            text: line[i],
            style: curStyle,
          ),
        );

        painter
          ..layout(
            maxWidth: isDoubleByte
                ? 2 * controller.theme.letterWidth
                : controller.theme.letterWidth,
            minWidth: isDoubleByte
                ? 2 * controller.theme.letterWidth
                : controller.theme.letterWidth,
          )
          ..paint(
            canvas,
            Offset(
              _position.dx * controller.theme.letterWidth,
              _position.dy * controller.theme.letterHeight,
            ),
          );

        // PrintUtil.printD('paint text end -> ${stopwatch.elapsed}', [31, 47, 7]);
        moveToNextOffset(1);
        if (isDoubleByte) {
          moveToNextOffset(1);
        }
      }
      if (j != outList.length - 1) {
        moveNewLineOffset();
      }
    }
    paintCursor(canvas);
    // drawLine(canvas);

    controller.dirty = false;
    PrintUtil.printd(
      '${'<' * 32} $this defaultOffsetY->$defaultOffsetY',
      32,
    );
  }

  void paintText(Canvas canva) {}

  void paintCursor(Canvas canvas) {
    if (!isOutTerm() && controller.showCursor) {
      canvas.drawRect(
        Rect.fromLTWH(
          _position.dx * controller.theme.letterWidth,
          _position.dy * controller.theme.letterHeight,
          controller.theme.letterWidth,
          controller.theme.letterHeight,
        ),
        Paint()..color = Colors.grey.withOpacity(0.4),
      );
    }
  }

  bool isOutTerm() {
    return _position.dy * controller.theme.letterHeight >= termHeight ||
        _position.dy * controller.theme.letterHeight < 0;
  }

  void moveToLineFirstOffset() {
    curPaintIndex = curPaintIndex - curPaintIndex % columnLength;
    _position = getCurPosition();
  }

  Position getCurPosition() {
    return Position(
      curPaintIndex % columnLength,
      curPaintIndex ~/ columnLength,
    );
  }

  void moveToNextOffset(int x) {
    curPaintIndex += x;
    _position = getCurPosition();
    // print(_position);
  }

  void moveNewLineOffset() {
    int tmp = columnLength - curPaintIndex % columnLength;
    curPaintIndex = tmp + curPaintIndex;
    _position = getCurPosition();
  }

  TextStyle getTextStyle(String tag, TextStyle preTextStyle) {
    switch (tag) {
      case '30':
        return preTextStyle.copyWith(
          color: controller.theme.black,
        );
        break;
      case '31':
        return preTextStyle.copyWith(
          color: controller.theme.red,
        );
        break;
      case '32':
        return preTextStyle.copyWith(
          color: controller.theme.green,
        );
        break;
      case '33':
        return preTextStyle.copyWith(
          color: controller.theme.yellow,
        );
        break;
      case '34':
        return preTextStyle.copyWith(
          color: controller.theme.blue,
        );
        break;
      case '35':
        return preTextStyle.copyWith(
          color: controller.theme.purplishRed,
        );
        break;
      case '36':
        return preTextStyle.copyWith(
          color: controller.theme.cyan,
        );
        break;
      case '37':
        return preTextStyle.copyWith(
          color: controller.theme.white,
        );
        break;
      case '42':
        return preTextStyle.copyWith(
          backgroundColor: controller.theme.green,
        );
        break;
      case '49':
        return preTextStyle.copyWith(
          backgroundColor: controller.theme.black,
          color: controller.theme.defaultColor,
        );
        break;
      case '0':
        return preTextStyle.copyWith(
          color: controller.theme.defaultColor,
          backgroundColor: Colors.transparent,
        );
        break;
      default:
        return preTextStyle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // return true;
    return controller.dirty;
  }
}
