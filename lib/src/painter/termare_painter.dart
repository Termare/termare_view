import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:termare_view/src/config/cache.dart';
import 'package:termare_view/src/core/safe_list.dart';
import 'package:termare_view/src/model/letter_eneity.dart';
import 'package:termare_view/src/termare_controller.dart';

TextLayoutCache painterCache = TextLayoutCache(TextDirection.ltr, 4096);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
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

  void drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    drawBackground(canvas, size);
    // 视图的真实高度
    final int startRow = controller.startLength;
    final int endRow = startRow + controller.rowLength;
    // print('startRow ->$startRow');
    for (int row = startRow; row < endRow; row++) {
      final SafeList<LetterEntity> line = controller.cache[row];

      // print('第 ${row - startRow} 行');
      if (line == null) {
        continue;
      }
      for (int x = 0; x < line.length; x++) {
        if (line[x] == null) {
          continue;
        }
        final LetterEntity letterEntity = line[x];
        final TextPainter painter = painterCache.getOrPerformLayout(
          TextSpan(
            text: letterEntity.content,
            style: TextStyle(
              fontSize: controller.theme.fontSize,
              backgroundColor: Colors.transparent,
              color: letterEntity.textAttributes.foreground(controller),
              fontWeight: FontWeight.w600,
              fontFamily: controller.fontFamily,
              // fontStyle: FontStyle
            ),
          ),
        );
        final Offset offset = Offset(
          x * controller.theme.letterWidth,
          (row - controller.startLength) * controller.theme.letterHeight,
        );
        // TODO 可能出bug，上面改了
        // print('${letterEntity.content} $offset');
        if (letterEntity.textAttributes.background(controller) != null) {
          // 当字符背景颜色不为空的时候
          canvas.drawRect(
            Rect.fromLTWH(
              // 下面是sao办法，解决neofetch显示的颜色方块中有缝隙
              offset.dx,
              offset.dy,
              letterEntity.doubleWidth
                  ? controller.theme.letterWidth * 2 + 2
                  : controller.theme.letterWidth + 2,
              controller.theme.letterHeight,
            ),
            Paint()..color = letterEntity.textAttributes.background(controller),
          );
        }

        painter
          ..layout(
            maxWidth: controller.theme.letterWidth * 2,
            minWidth: controller.theme.letterWidth,
          )
          ..paint(
            canvas,
            offset +
                Offset(0, (controller.theme.letterHeight - painter.height) / 2),
          );
      }
    }

    if (controller.showBackgroundLine) {
      drawLine(canvas);
    }
    controller.dirty = false;

    paintCursor(canvas, controller.startLength);
    final int absLength = controller.absoluteLength();
    if (absLength > controller.rowLength + controller.startLength) {
      print(
          '自动滑动 absLength:$absLength controller.rowLength:${controller.rowLength} controller.startLength:${controller.startLength}');
      // 上面这个if其实就是当终端视图下方还有显示内容的时候
      if (controller.autoScroll) {
        // 只能延时执行刷新
        Future.delayed(const Duration(milliseconds: 10), () {
          controller.startLength +=
              absLength - controller.startLength - controller.rowLength;
          controller.dirty = true;
          controller.notifyListeners();
        });
        // lastLetterPositionCall(
        //   -controller.theme.letterHeight *
        //       (controller.cache.length - realColumnLen - controller.startLine),
        // );
      }
    } else {
      // if (controller.autoScroll) {
      //   // 只能延时执行刷新
      //   Future.delayed(const Duration(milliseconds: 10), () {
      //     controller.startLength =
      //         absLength - controller.startLength - controller.rowLength;
      //     controller.dirty = true;
      //     controller.notifyListeners();
      //   });
      //   // lastLetterPositionCall(
      //   //   -controller.theme.letterHeight *
      //   //       (controller.cache.length - realColumnLen - controller.startLine),
      //   // );
      // }
    }
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
        Paint()..color = controller.theme.cursorColor.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // return true;
    return controller.dirty;
  }
}
