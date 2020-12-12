import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:termare_view/src/config/cache.dart';
import 'package:termare_view/src/model/letter_eneity.dart';
import 'package:termare_view/src/termare_controller.dart';

TextLayoutCache painterCache = TextLayoutCache(TextDirection.ltr, 4096);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
    this.color = Colors.white,
  }) {
    termWidth = controller.columnLength * controller.theme.letterWidth;
    termHeight = controller.rowLength * controller.theme.letterHeight;
  }
  final TermareController controller;
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
  double padding;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
  final Stopwatch stopwatch = Stopwatch();
  void drawLine(Canvas canvas) {
    final Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Colors.grey.withOpacity(0.4);
    for (int j = 0; j <= controller.rowLength; j++) {
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
    for (int k = 0; k <= controller.columnLength; k++) {
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
    final int realColumnLen = math.min(
      controller.cache.length,
      controller.rowLength,
    );
    // PrintUtil.printD('realColumnLen->$realColumnLen', [31]);
    for (int y = 0; y < realColumnLen; y++) {
      if (y + controller.startLine >= controller.cache.length) {
        break;
      }
      final List<LetterEntity> line =
          controller.cache[y + controller.startLine];
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
            style: letterEntity.textStyle.copyWith(
              fontSize: controller.theme.fontSize,
            ),
          ),
        );
        painter
          ..layout(
            maxWidth: controller.theme.letterWidth * 2,
            minWidth: controller.theme.letterWidth,
          )
          ..paint(
            canvas,
            Offset(
              letterEntity.position.x * controller.theme.letterWidth,
              (letterEntity.position.y - controller.startLine) *
                      controller.theme.letterHeight +
                  2,
            ),
          );
      }
    }

    if (controller.showBackgroundLine) {
      drawLine(canvas);
    }
    controller.dirty = false;

    paintCursor(canvas, controller.startLine);
    if (controller.cache.length > realColumnLen + controller.startLine) {
      if (controller.autoScroll) {
        Future.delayed(const Duration(milliseconds: 10), () {
          controller.startLine += controller.cache.length -
              controller.startLine -
              controller.rowLength +
              1;
          controller.dirty = true;
          controller.notifyListeners();
        });
        // lastLetterPositionCall(
        //   -controller.theme.letterHeight *
        //       (controller.cache.length - realColumnLen - controller.startLine),
        // );
      }
    } else {}
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
