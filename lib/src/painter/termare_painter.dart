import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:termare_view/src/config/cache.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/core/safe_list.dart';
import 'package:termare_view/src/core/letter_eneity.dart';
import 'package:termare_view/src/termare_controller.dart';

TextLayoutCache painterCache = TextLayoutCache(TextDirection.ltr, 4096);

class TermarePainter extends CustomPainter {
  TermarePainter({
    this.controller,
  }) {
    termWidth = controller.column * controller.theme.characterWidth;
    termHeight = controller.row * controller.theme.characterHeight;
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
    for (int j = 0; j <= controller.row; j++) {
      canvas.drawLine(
        Offset(
          0,
          j * controller.theme.characterHeight,
        ),
        Offset(
          termWidth,
          j * controller.theme.characterHeight,
        ),
        paint,
      );
    }
    for (int k = 0; k <= controller.column; k++) {
      canvas.drawLine(
        Offset(
          k * controller.theme.characterWidth,
          0,
        ),
        Offset(k * controller.theme.characterWidth, termHeight),
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
    final Buffer buffer = controller.buffer;
    // 视图的真实高度
    for (int row = 0; row < controller.row; row++) {
      for (int column = 0; column < controller.column; column++) {
        final Character character = buffer.getCharacter(row, column);
        if (character == null) {
          continue;
        }
        final TextPainter painter = painterCache.getOrPerformLayout(
          TextSpan(
            text: character.content,
            style: TextStyle(
              fontSize: controller.theme.fontSize,
              backgroundColor: Colors.transparent,
              color: character.textAttributes.foreground(controller),
              fontWeight: FontWeight.w600,
              fontFamily: controller.fontFamily,
              // fontStyle: FontStyle
            ),
          ),
        );
        final Offset offset = Offset(
          column * controller.theme.characterWidth,
          row * controller.theme.characterHeight,
        );
        // TODO 可能出bug，上面改了
        // print('${letterEntity.content} $offset');
        if (character.textAttributes.background(controller) != null) {
          // 当字符背景颜色不为空的时候
          canvas.drawRect(
            Rect.fromLTWH(
              // 下面是sao办法，解决neofetch显示的颜色方块中有缝隙
              offset.dx,
              offset.dy,
              character.doubleWidth
                  ? controller.theme.characterWidth * 2 + 2
                  : controller.theme.characterWidth + 2,
              controller.theme.characterHeight,
            ),
            Paint()..color = character.textAttributes.background(controller),
          );
        }

        painter
          ..layout(
            maxWidth: controller.theme.characterWidth * 2,
            minWidth: controller.theme.characterWidth,
          )
          ..paint(
            canvas,
            offset +
                Offset(
                    0, (controller.theme.characterHeight - painter.height) / 2),
          );
      }
    }

    if (controller.showBackgroundLine) {
      drawLine(canvas);
    }
    controller.dirty = false;

    paintCursor(canvas, buffer);
    print('controller.currentPointer.y -> ${controller.currentPointer.y}');
    print('buffer.limit -> ${buffer.limit}');
    if (controller.currentPointer.y + 1 > buffer.limit) {
      // print(
      //     '自动滑动 absLength:$absLength controller.rowLength:${controller.rowLength} controller.startLength:${controller.startLength}');
      // 上面这个if其实就是当终端视图下方还有显示内容的时候
      if (controller.autoScroll) {
        print('滚动 pointer ${controller.currentPointer}');
        // 只能延时执行刷新
        // print(controller.currentPointer.y + 1 - buffer.limit);
        Future.delayed(const Duration(milliseconds: 10), () {
          buffer.scroll(controller.currentPointer.y + 1 - buffer.limit);
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

  void paintCursor(Canvas canvas, Buffer buffer) {
    if (controller.showCursor) {
      canvas.drawRect(
        Rect.fromLTWH(
          controller.currentPointer.dx * controller.theme.characterWidth,
          (controller.currentPointer.dy - buffer.position) *
              controller.theme.characterHeight,
          controller.theme.characterWidth,
          controller.theme.characterHeight,
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
