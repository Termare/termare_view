import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:termare/src/config/cache.dart';
import 'package:termare/src/painter/model/position.dart';
import 'package:termare/src/termare_controller.dart';
import 'package:termare/src/theme/term_theme.dart';

const double letterWidth = 8.0;
const double letterHeight = 16.0;

// int rowLength = 80;
// int columnLength = 24;
TextLayoutCache cache = TextLayoutCache(TextDirection.ltr, 4068);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
    this.theme,
    this.rowLength,
    this.columnLength,
    this.defaultOffsetY,
    this.color = Colors.white,
    this.input,
    this.lastLetterPositionCall,
  }) {
    termWidth = columnLength * letterWidth;
    termHeight = rowLength * letterHeight;
  }
  final TermareController controller;
  final int rowLength;
  final int columnLength;
  double termWidth;
  double termHeight;
  int curPaintIndex = 0;
  final TermTheme theme;
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
  Function eq = const ListEquality().equals;
  Position _position = Position(0, 0);

  TextStyle defaultStyle = TextStyle(
    textBaseline: TextBaseline.ideographic,
    height: 1,
    fontSize: 14.0,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    // backgroundColor: Colors.black,
    fontFamily: 'monospace',
  );
  void drawLine(Canvas canvas) async {
    Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Colors.grey.withOpacity(0.4);
    for (int j = 0; j <= rowLength; j++) {
      // print(j);
      canvas.drawLine(
        Offset(0, j * letterHeight),
        Offset(
          termWidth,
          j * letterHeight,
        ),
        paint,
      );
    }
    for (int k = 0; k <= columnLength; k++) {
      canvas.drawLine(
        Offset(
          k * letterWidth,
          0,
        ),
        Offset(k * letterWidth, termHeight),
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
    _position = Position(0, 0);
    curPaintIndex = 0;
    drawBackground(canvas);
    // print('_position->$_position');
    TextStyle curStyle = defaultStyle;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '\n') {
        moveNewLineOffset();
        continue;
      }
      // print(input[i]);
      // print(input[i].codeUnits);
      if (eq(input[i].codeUnits, [0x07])) {
        // print('<- C0 Bell ->');
        continue;
      }
      if (eq(input[i].codeUnits, [0x08])) {
        // 光标左移动
        // print('<- C0 Backspace ->');
        final RegExp doubleByteReg = RegExp('[^\x00-\xff]');
        bool isDoubleByte = doubleByteReg.hasMatch(input[i - 1]);
        if (isDoubleByte) {
          // print('双字节字符---->${input[i]}');
          moveToNextOffset(-1);
        }
        moveToNextOffset(-1);
        continue;
      }

      if (eq(input[i].codeUnits, [0x09])) {
        moveToNextOffset(4);
        // print('<- Horizontal Tabulation ->');
        continue;
      }
      if (eq(input[i].codeUnits, [0x0a])) {
        // print('<- C0 	Line Feed ->');
        continue;
      }
      if (eq(input[i].codeUnits, [0x1b])) {
        // print('<- ESC ->');
        String nextStr = input[i + 1];
        print('curStr->${input[i]} nextStr->$nextStr');
        switch (nextStr) {
          case '[':
            String nextStr = input[i + 2];
            print('[->nextStr->$nextStr');
            switch (nextStr) {
              case 'K':
                i += 2;
                final RegExp doubleByteReg = RegExp('[^\x00-\xff]');
                bool isDoubleByte = doubleByteReg.hasMatch(input[i]);
                if (isDoubleByte) {
                  // print('数按字节字符---->${input[i]}');
                }
                canvas.drawRect(
                  Rect.fromLTWH(
                    _position.dx * letterWidth,
                    _position.dy * letterHeight + defaultOffsetY,
                    isDoubleByte ? 2 * letterWidth : letterWidth,
                    letterHeight,
                  ),
                  Paint()..color = Colors.black,
                );
                continue;
                break;
              default:
            }
            // print(input.substring(i + 2));
            final int charMindex = input.substring(i + 1).indexOf('m');

            // print('charMindex=======>$charMindex');
            String header = '';
            header = input.substring(i + 2, i + 1 + charMindex);
            for (var str in header.split(';')) {
              curStyle = getTextStyle(str, curStyle);
              // switch (str) {
              //   case '1':
              //     break;
              //   default:
              // }
            }
            i += header.length + 1;
            // print('header->$header');
            // for (int j = i + 2; j < input.length; j++) {
            //   print(input[j]);
            // }
            i++;
            break;
          default:
        }

        continue;
      }
      if (eq(input[i].codeUnits, [0x0d])) {
        moveToLineFirstOffset();
        // print('<- 将光标移动到行的开头。 ->');

        continue;
      }
      // print(input[i] == utf8.decode(TermControlSequences.buzzing));
      // canvas.drawRect(
      //   Rect.fromLTWH(curOffset * width.toDouble(), 0.0, 16, 16),
      //   Paint()..color = Colors.white,
      // );
      if (isOutTerm()) {
        continue;
      }

      final RegExp doubleByteReg = RegExp('[^\x00-\xff]');
      bool isDoubleByte = doubleByteReg.hasMatch(input[i]);
      if (isDoubleByte) {
        // print('数按字节字符---->${input[i]}');
      }
      canvas.drawRect(
        Rect.fromLTWH(
          _position.dx * letterWidth,
          _position.dy * letterHeight + defaultOffsetY,
          isDoubleByte ? 2 * letterWidth : letterWidth,
          letterHeight,
        ),
        Paint()..color = Colors.black,
      );
      TextPainter painter = cache.getOrPerformLayout(
        TextSpan(
          text: input[i],
          style: curStyle,
        ),
      );
      painter
        ..layout(
          maxWidth: isDoubleByte ? 2 * letterWidth : letterWidth,
          minWidth: isDoubleByte ? 2 * letterWidth : letterWidth,
        )
        ..paint(
          canvas,
          Offset(
            _position.dx * letterWidth,
            _position.dy * letterHeight + defaultOffsetY,
          ),
        );

      moveToNextOffset(1);
      if (isDoubleByte) {
        moveToNextOffset(1);
      }
    }
    paintCursor(canvas);
    drawLine(canvas);
    lastLetterPositionCall?.call(
      _position.dy * letterHeight + defaultOffsetY - termHeight + letterHeight,
    );
    controller.dirty = false;
  }

  void paintCursor(Canvas canvas) {
    if (!isOutTerm()) {
      canvas.drawRect(
        Rect.fromLTWH(
            _position.dx * letterWidth,
            _position.dy * letterHeight + defaultOffsetY,
            letterWidth,
            letterHeight),
        Paint()..color = Colors.grey.withOpacity(0.4),
      );
    }
  }

  bool isOutTerm() {
    return _position.dy * letterHeight + defaultOffsetY >= termHeight ||
        _position.dy * letterHeight + defaultOffsetY < 0;
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
          color: theme.black,
        );
        break;
      case '31':
        return preTextStyle.copyWith(
          color: theme.red,
        );
        break;
      case '32':
        return preTextStyle.copyWith(
          color: theme.green,
        );
        break;
      case '33':
        return preTextStyle.copyWith(
          color: theme.yellow,
        );
        break;
      case '34':
        return preTextStyle.copyWith(
          color: theme.blue,
        );
        break;
      case '35':
        return preTextStyle.copyWith(
          color: theme.purplishRed,
        );
        break;
      case '36':
        return preTextStyle.copyWith(
          color: theme.cyan,
        );
        break;
      case '37':
        return preTextStyle.copyWith(
          color: theme.white,
        );
        break;
      case '42':
        return preTextStyle.copyWith(
          backgroundColor: theme.green,
        );
        break;
      case '49':
        return preTextStyle.copyWith(
          backgroundColor: theme.black,
          color: theme.defaultColor,
        );
        break;
      case '0':
        return preTextStyle.copyWith(
          color: theme.defaultColor,
          backgroundColor: Colors.transparent,
        );
        break;
      default:
        return preTextStyle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
    return controller.dirty;
  }
}
