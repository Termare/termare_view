import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare/src/config/cache.dart';
import 'package:termare/src/model/letter_eneity.dart';
import 'package:termare/src/painter/model/position.dart';
import 'package:termare/src/termare_controller.dart';
import 'dart:math' as math;

TextLayoutCache painterCache = TextLayoutCache(TextDirection.ltr, 4096);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
    this.rowLength,
    this.columnLength,
    this.defaultOffsetY,
    this.color = Colors.white,
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
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

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
    final int outLine =
        -defaultOffsetY.toInt() ~/ controller.theme.letterHeight.toInt();
    // PrintUtil.printD('outLine->$outLine', [31]);
    final int realColumnLen = math.min(
      controller.cache.length,
      controller.rowLength,
    );
    // PrintUtil.printD('realColumnLen->$realColumnLen', [31]);
    for (int y = 0; y < realColumnLen; y++) {
      if (y + outLine >= controller.cache.length) {
        break;
      }
      final List<LetterEntity> line = controller.cache[y + outLine];
      if (line == null) {
        continue;
      }
      // PrintUtil.printD('line->$line', [31]);
      for (int x = 0; x < line.length; x++) {
        if (line[x] == null) {
          continue;
        }
        final LetterEntity letterEntity = line[x];
        final TextPainter painter = painterCache.getOrPerformLayout(
          TextSpan(
            text: letterEntity.content,
            style: letterEntity.textStyle,
          ),
        );
        painter
          ..layout(
            maxWidth: letterEntity.letterWidth,
            minWidth: letterEntity.letterWidth,
          )
          ..paint(
            canvas,
            Offset(
              letterEntity.position.x * controller.theme.letterWidth,
              (letterEntity.position.y - outLine) *
                  controller.theme.letterHeight,
            ),
          );
      }
    }

    if (controller.cache.length > realColumnLen + outLine) {
      // TODO  应该滑动上去一点
      if (controller.autoScroll) {
        lastLetterPositionCall(
          -controller.theme.letterHeight *
              (controller.cache.length - realColumnLen - outLine),
        );
      }
    } else {}
    controller.dirty = false;

    drawLine(canvas);

    paintCursor(canvas, outLine);
  }

  void paintText(Canvas canva) {}

  void paintCursor(Canvas canvas, int outLine) {
    if (controller.showCursor) {
      canvas.drawRect(
        Rect.fromLTWH(
          controller.currentPointer.dx * controller.theme.letterWidth,
          controller.currentPointer.dy * controller.theme.letterHeight -
              outLine * controller.theme.letterHeight,
          controller.theme.letterWidth,
          controller.theme.letterHeight,
        ),
        Paint()..color = Colors.grey.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // return true;
    return controller.dirty;
  }
}
