import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:termare_view/src/utils/cache.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/foundation/character.dart';
import 'package:termare_view/src/foundation/text_attribute.dart';
import 'package:termare_view/src/termare_controller.dart';
import 'package:termare_view/src/theme/term_theme.dart';
import 'package:termare_view/src/utils/signale/signale.dart';

TextLayoutCache painterCache = TextLayoutCache(TextDirection.ltr, 8192);

// 终端组件的Painter，也是比较重要的部分
class TermarePainter extends CustomPainter {
  TermarePainter({
    required this.controller,
  }) {
    offsetCache.length = controller.row;
    // print('TermarePainter构造');
    termWidth = controller.column * controller.theme!.characterWidth!;
    termHeight = controller.row * controller.theme!.characterHeight!;

    for (int row = 0; row < controller.row; row++) {
      for (int column = 0; column < controller.column; column++) {
        if (offsetCache[row] == null) {
          offsetCache[row] = [];
          offsetCache[row].length = controller.column;
        }
        offsetCache[row][column] = Offset(
          column * controller.theme!.characterWidth!,
          row * controller.theme!.characterHeight!,
        );
        // Log.e('第$row行 第$column列的 offset 为 ${offsetCache[row][column]}');
      }
    }
    // Log.d('0 0 offset 为 ${offsetCache[0][0]}');
    // cacheOffset();
  }
  List<List<Offset>> offsetCache = [];
  Future<void> cacheOffset() async {
    for (int row = 0; row < controller.row; row++) {
      for (int column = 0; column < controller.column; column++) {
        if (offsetCache[row] == null) {
          offsetCache[row] = [];
          offsetCache[row].length = controller.column;
        }
        offsetCache[row][column] = Offset(
          column * controller.theme!.characterWidth!,
          row * controller.theme!.characterHeight!,
        );
        // Log.e('第$row行 第$column列的 offset 为 ${offsetCache[row][column]}');
      }
    }
  }

  /// 终端控制器
  late final TermareController controller;

  late double termWidth;
  late double termHeight;

  double? padding;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
  void drawLine(Canvas canvas) {
    final Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Colors.grey.withOpacity(0.4);
    for (int j = 0; j <= controller.row; j++) {
      canvas.drawLine(
        Offset(
          0,
          j * controller.theme!.characterHeight!,
        ),
        Offset(
          termWidth,
          j * controller.theme!.characterHeight!,
        ),
        paint,
      );
    }
    for (int k = 0; k <= controller.column; k++) {
      canvas.drawLine(
        Offset(
          k * controller.theme!.characterWidth!,
          0,
        ),
        Offset(k * controller.theme!.characterWidth!, termHeight),
        paint,
      );
    }
  }

  void drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = controller.theme!.backgroundColor,
    );
  }

  // void log(Object object) {
  //   if (stopwatch.elapsed > const Duration(milliseconds: 11)) {
  //     Log.e(object);
  //   } else {
  //     Log.d(object);
  //   }
  // }

  final Stopwatch stopwatch = Stopwatch();
  @override
  void paint(Canvas canvas, Size size) {
    stopwatch.reset();
    stopwatch.start();
    final TermareStyle? theme = controller.theme;
    // Log.d('init : ${stopwatch.elapsed}');
    // drawBackground(canvas, size);
    // Log.d('paint background : ${stopwatch.elapsed}');
    final Buffer? buffer = controller.currentBuffer;
    for (int row = 0; row < controller.row; row++) {
      for (int column = 0; column < controller.column; column++) {
        final Character? character = buffer!.getCharacter(row, column);
        if (character == null) {
          continue;
        }
        final TextAttribute attributes = character.textAttributes!;
        final Color? foreground = attributes.getForegroundColor(controller);

        final Color? background = attributes.getBackgroundColor(controller);
        // print(
        //     '缓存 -> ${character.content} ${character.content.codeUnits} ${character.content.codeUnitAt(0) == 65533}');

        TextPainter painter;
        try {
          painter = painterCache.getOrPerformLayout(
            TextSpan(
              text: character.content,
              style: TextStyle(
                fontSize: controller.theme!.fontSize,
                color: foreground,
                fontFamilyFallback: [
                  controller.fontFamily,
                ],
                height: 1.0,
                // fontStyle: FontStyle
              ),
            ),
          );
        } catch (e) {
          Log.i('发现错误字符，提花成空格');
          // 在 utf 解码的时候，使用了 allowMalformed=true，编码失败会将失败的字符改为�，
          // 这个字符画不出来
          painter = painterCache.getOrPerformLayout(
            TextSpan(
              text: ' ',
              style: TextStyle(
                fontSize: controller.theme!.fontSize,
                color: foreground,
                fontFamilyFallback: [
                  controller.fontFamily,
                ],
                height: 1.0,
                // fontStyle: FontStyle
              ),
            ),
          );
        }
        // log('get painter ${stopwatch.elapsed}');
        // print(
        //   'character.content -> ${character.content} painter.height -> ${painter.height}  painter.width -> ${painter.width}',
        // );
        // print('painter->${painter.height}');
        // print('painter->${painter.size}');
        final bool isDoubleWidth = character.wcwidth == 2;
        // final double doubleWidthXOffset = isDoubleWidth ? 0 : 0;
        // final double doubleWidthYOffset = isDoubleWidth ? 0 : 0;
        final Offset backOffset = offsetCache[row][column];

        // log('get offset ${stopwatch.elapsed}');
        final Offset fontOffset = backOffset +
            Offset(0, (theme!.characterHeight! - painter.height) / 2);
        if (background != controller.theme!.backgroundColor) {
          // 当字符背景颜色不为空的时候
          // print('字符背景颜色不为空的时候');
          //
          // 下面是解决neofetch显示的颜色方块中有缝隙
          //
          final double backWidth = isDoubleWidth
              ? controller.theme!.characterWidth! * 2 + 0.6
              : controller.theme!.characterWidth! + 0.6;
          final Paint backPaint = Paint();
          backPaint.color = background!;
          canvas.drawRect(
            Rect.fromLTWH(
              backOffset.dx,
              backOffset.dy,
              backWidth,
              controller.theme!.characterHeight!,
            ),
            backPaint,
          );
        }
        painter
          ..layout(
            maxWidth: controller.theme!.characterHeight!,
            minWidth: controller.theme!.characterWidth!,
          )
          ..paint(
            canvas,
            fontOffset,
          );
      }
    }
    if (controller.showBackgroundLine) {
      drawLine(canvas);
    }
    paintCursor(canvas, buffer!);
    controller.forbidBuild();
    Future.delayed(const Duration(milliseconds: 10), () {
      controller.schedulingRead?.call();
    });
  }

  void paintText(Canvas canva) {}

  void paintCursor(Canvas canvas, Buffer buffer) {
    final bool isNotOverFlow =
        controller.currentPointer.dy - buffer.position < controller.row;
    if (controller.showCursor && isNotOverFlow) {
      final Paint paint = Paint()
        ..color = controller.theme!.cursorColor
        ..strokeWidth = 0.5;
      if (!controller.hasFocus) {
        paint.style = PaintingStyle.stroke;
      }
      final int x = controller.currentPointer.x;
      final int y = controller.currentPointer.y - buffer.position;
      final Character? character = buffer.getCharacter(y, x);
      if (character != null && !character.isEmpty) {
        paint.blendMode = BlendMode.hardLight;
      }
      // paint.blendMode = BlendMode.exclusion;
      // paint.blendMode = BlendMode.xor;
      double cursorWidth = controller.theme!.characterWidth!;
      if (character != null && character.wcwidth == 2) {
        cursorWidth *= 2;
      }
      canvas.drawRect(
        Rect.fromLTWH(
          x * controller.theme!.characterWidth!,
          y * controller.theme!.characterHeight!,
          cursorWidth,
          controller.theme!.characterHeight!,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return controller.isDirty;
  }
}
