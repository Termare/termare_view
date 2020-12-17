import 'dart:math' as math;
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
      final SafeList<LetterEntity> line =
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
            style: TextStyle(
              fontSize: controller.theme.fontSize,
              backgroundColor: Colors.transparent,
              color: getFontColor(
                letterEntity.fontColorTag,
                letterEntity.foregroundColor,
              ),
              fontWeight: FontWeight.w600,
              fontFamily: controller.fontFamily,
              // fontStyle: FontStyle
            ),
          ),
        );
        final Offset offset = Offset(
          letterEntity.position.x * controller.theme.letterWidth,
          (letterEntity.position.y - controller.startLine) *
              controller.theme.letterHeight,
        );
        if (letterEntity.backgroundColorTag != '0') {
          // 当字符背景颜色不为空的时候
          canvas.drawRect(
            Rect.fromLTWH(
              // 下面是扫办法，解决neofetch显示的颜色方块中有缝隙
              offset.dx - 1,
              offset.dy,
              letterEntity.doubleWidth
                  ? controller.theme.letterWidth * 2 + 2
                  : controller.theme.letterWidth + 2,
              controller.theme.letterHeight,
            ),
            Paint()
              ..color = getBackgroundColor(
                letterEntity.backgroundColorTag,
                letterEntity.backgroundColor,
              ),
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

  Color getFontColor(String tag, String hightTag) {
    final bool higlt = hightTag == '38';
    switch (tag) {
      case '8':
        if (higlt) {
          return controller.theme.black;
        }
        return controller.theme.lightBlack;
        break;
      case '9':
        if (higlt) {
          return controller.theme.red;
        }
        return controller.theme.lightRed;
        break;
      case '10':
        if (higlt) {
          return controller.theme.green;
        }
        return controller.theme.lightGreen;
        break;
      case '11':
        if (higlt) {
          return controller.theme.yellow;
        }
        return controller.theme.lightYellow;
        break;
      case '12':
        if (higlt) {
          return controller.theme.blue;
        }
        return controller.theme.lightBlue;
        break;
      case '13':
        if (higlt) {
          return controller.theme.purplishRed;
        }
        return controller.theme.lightPurplishRed;
        break;
      case '14':
        if (higlt) {
          return controller.theme.cyan;
        }
        return controller.theme.lightCyan;
        break;
      case '15':
        if (higlt) {
          return controller.theme.white;
        }
        return controller.theme.lightWhite;
        break;
    }
    switch (tag) {
      case '30':
        if (higlt) {
          return controller.theme.black;
        }
        return controller.theme.lightBlack;
        break;
      case '31':
        if (higlt) {
          return controller.theme.red;
        }
        return controller.theme.lightRed;
        break;
      case '32':
        if (higlt) {
          return controller.theme.green;
        }
        return controller.theme.lightGreen;
        break;
      case '33':
        if (higlt) {
          return controller.theme.yellow;
        }
        return controller.theme.lightYellow;
        break;
      case '34':
        if (higlt) {
          return controller.theme.blue;
        }
        return controller.theme.lightBlue;
        break;
      case '35':
        if (higlt) {
          return controller.theme.purplishRed;
        }
        return controller.theme.lightPurplishRed;
        break;
      case '36':
        if (higlt) {
          return controller.theme.cyan;
        }
        return controller.theme.lightCyan;
        break;
      case '37':
        if (higlt) {
          return controller.theme.white;
        }
        return controller.theme.lightWhite;
        break;
      default:
        return controller.theme.defaultColor;
    }
  }

  Color getBackgroundColor(String tag, String hightTag) {
    final bool defaultColor = hightTag == '49';
    print('hightTag->${hightTag}');
    switch (tag) {
      case '8':
        if (defaultColor) {
          return controller.theme.black;
        }
        return controller.theme.lightBlack;
        break;
      case '9':
        if (defaultColor) {
          return controller.theme.red;
        }
        return controller.theme.lightRed;
        break;
      case '10':
        if (defaultColor) {
          return controller.theme.green;
        }
        return controller.theme.lightGreen;
        break;
      case '11':
        if (defaultColor) {
          return controller.theme.yellow;
        }
        return controller.theme.lightYellow;
        break;
      case '12':
        if (defaultColor) {
          return controller.theme.blue;
        }
        return controller.theme.lightBlue;
        break;
      case '13':
        if (defaultColor) {
          return controller.theme.purplishRed;
        }
        return controller.theme.lightPurplishRed;
        break;
      case '14':
        if (defaultColor) {
          return controller.theme.cyan;
        }
        return controller.theme.lightCyan;
        break;
      case '15':
        if (defaultColor) {
          return controller.theme.white;
        }
        return controller.theme.lightWhite;
        break;
    }
    switch (tag) {
      case '40':
        if (defaultColor) {
          return controller.theme.black;
        }
        return controller.theme.lightBlack;
        break;
      case '41':
        if (defaultColor) {
          return controller.theme.red;
        }
        return controller.theme.lightRed;
        break;
      case '42':
        if (defaultColor) {
          return controller.theme.green;
        }
        return controller.theme.lightGreen;
        break;
      case '43':
        if (defaultColor) {
          return controller.theme.yellow;
        }
        return controller.theme.lightYellow;
        break;
      case '44':
        if (defaultColor) {
          return controller.theme.blue;
        }
        return controller.theme.lightBlue;
        break;
      case '45':
        if (defaultColor) {
          return controller.theme.purplishRed;
        }
        return controller.theme.lightPurplishRed;
        break;
      case '46':
        if (defaultColor) {
          return controller.theme.cyan;
        }
        return controller.theme.lightCyan;
        break;
      case '47':
        if (defaultColor) {
          return controller.theme.white;
        }
        return controller.theme.lightWhite;
        break;
      default:
        return controller.theme.black;
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
