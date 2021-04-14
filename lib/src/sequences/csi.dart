import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/core/character.dart';
import 'package:termare_view/src/core/text_attributes.dart';
import 'package:termare_view/src/painter/position.dart';
import 'package:termare_view/termare_view.dart';

typedef CsiHandler = void Function(
    TermareController controller, String sequence);
bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

Map<String, CsiHandler> csiSeqHandlerMap = {
  '@': insertCharactersHandler, //0
  'A': cursorUp, //1
  'B': cursorDown, //2
  'C': cursorForward, //3
  'D': cursorBackward, //4
  'E': cursorNextLine, //5
  'F': cursorBackwardAndToFirstColumn, //6
  'G': cursorHorizontalAbsolute, //7
  'H': cursorPosition, //8
  'I': cursorHorizontalTabulation, //9
  'J': selectiveEraseInDisplay, //10
  'K': eraseInLine, //11
  'L': insertLine, //12
  'M': deleteLine, //13
  'P': deleteCharacter, //14
  'S': scrollUp, //15
  'T': scrollDown, //16
  'X': eraseCharacter, //17
  'Z': cursorBackwardTabulation, //18
  '`': horizontalPositionAbsolute, //19
  'a': horizontalPositionRelative, //20
  'b': repeatPrecedingCharacter, //21
  'c': primaryDeviceAttributes, //22
  'd': verticalPositionAbsolute, //23
  'e': verticalPositionRelative, //24
  'f': horizontalandVerticalPosition, //25
  'g': tabClear, //26
  'h': setMode, //27
  'l': resetMode, //28
  'm': selectGraphicRendition, //29
  'n': deviceStatusReport, //30
  'p': softTerminalReset, //31
  'q': setCursorStyle, //32
  'r': setTopandBottomMargin, //33
  's': saveCursor, //34
  'u': restoreCursor, //35
  '}': insertColumns, //36
  '~': deleteColumns, //37
};
void insertCharactersHandler(TermareController controller, String sequence) {
  final Buffer buffer = controller.currentBuffer;

  /// @ ICH Insert Characters
  /// 向当前所在的位置添加一个空白字符
  /// ICH序列插入Ps空白字符。光标停留在空白字符的开头。光标和右边距之间的文本向右移动。超过右边距的字符将丢失。
  /// 还有点问题，下次记得找一下实际用到的序列
  //TODO
  final int ps = int.tryParse(sequence);
  for (int i = 0; i < ps; i++) {
    final int startColumn = controller.currentPointer.x;
    // print('startColumn $startColumn');
    final int endColumn = controller.column;
    for (int c = endColumn; c > startColumn; c--) {
      String source =
          buffer.getCharacter(controller.currentPointer.y, c - 1)?.content;
      String target =
          buffer.getCharacter(controller.currentPointer.y, c)?.content;
      // print('移动 ${c - 1}的$source 到 $c的$target');
      // print('移动 $source 到 $target');
      buffer.write(
        controller.currentPointer.y,
        c,
        buffer.getCharacter(controller.currentPointer.y, c - 1),
      );
    }
    controller.writeChar(' ');
  }
  controller.moveToRelativeColumn(-ps);
}

void cursorUp(TermareController controller, String sequence) {
  // A CUU 	Cursor Up
  /// 向上移动光标
  controller.log('$blue CSI Cursor Up');
  int ps = int.tryParse(sequence);

  /// ps 默认为1
  ps ??= 1;
  controller.moveToRelativeRow(-ps);
}

void cursorDown(TermareController controller, String sequence) {
  // B CUD Cursor Down
  /// 向下移动光标
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(ps);
}

void cursorForward(TermareController controller, String sequence) {
  // C CUF Cursor Forward
  /// 向前移动光标
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToPosition(ps);
}

void cursorBackward(TermareController controller, String sequence) {
  // D CUB Cursor Backward
  /// 向后移动光标
  int ps = int.tryParse(sequence);
  ps ??= 1;
  print('ps -> $ps');
  if (ps < 100) {
    /// 有的时候会有 999999D，例如在执行 neofetch 的时候会用到这个序列
    /// 但实际移动不了那么多
    controller.moveToPosition(-ps);
  }
}

void cursorNextLine(TermareController controller, String sequence) {
  /// E CNL Cursor Next Line
  /// 跟 CUD 差不多，另外需要将光标移动到第一行
  int ps = int.tryParse(sequence);
  ps ??= 1;
  print('ps -> $ps');
  controller.moveToRelativeRow(ps);
  controller.moveToLineFirstPosition();
}

void cursorBackwardAndToFirstColumn(
    TermareController controller, String sequence) {
  /// F CPL Cursor Backward
  /// 跟 CUU 差不多，另外需要将光标移动到第一行
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(-ps);
  controller.moveToLineFirstPosition();
}

void cursorHorizontalAbsolute(TermareController controller, String sequence) {
  /// G CHA	Cursor Horizontal Absolute
  /// 将光标移动到绝对定位列
  print('将光标移动到绝对定位列');
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToAbsoluteColumn(ps);
  // print('Cursor Horizontal Absolute ps=$ps');
}

void cursorPosition(TermareController controller, String sequence) {
  print(' H CUP	Cursor Position');

  /// H CUP	Cursor Position
  /// 将光标设置到位置: [Ps, Ps]
  /// [1,1]代表左上角
  // 说明是esc [H
  // 如果设置了原始模式，则将光标置于滚动边距内的绝对位置。
  // 如果未设置ORIGIN模式，请将光标置于视口内的绝对位置。
  // 请注意，坐标是从1开始的，因此左上角的位置从开始1 ; 1。
  /// TODO ORIGIN模式
  if (sequence.isEmpty) {
    sequence = '1;1';
  }
  final int row = int.parse(sequence.split(';')[0]);
  final int column = int.parse(sequence.split(';')[1]);
  print('row $row column $column');
  controller.moveToOffset(column, row);
  controller.currentBuffer.isCsiR = true;
  print('${controller.currentPointer}');
}

void cursorHorizontalTabulation(TermareController controller, String sequence) {
  /// I CHT	Cursor Horizontal Tabulation
  /// 光标向右移动 ps 个 tab 的位置
  /// 这里自己测出 tab 在终端的位置有5个终端字符
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToPosition(ps * 5);
}

void selectiveEraseInDisplay(TermareController controller, String sequence) {
  /// J DECSED	Selective Erase In Display
  /// 清空显示的字符
  /// 0	Erase from the cursor through the end of the viewport.
  /// 1	Erase from the beginning of the viewport through the cursor.
  /// 2	Erase complete viewport.
  /// 3	Erase scrollback.
  final Buffer buffer = controller.currentBuffer;
  sequence = sequence.replaceAll('?', '');
  int ps = int.tryParse(sequence);
  ps ??= 0;
  print('ps $ps');
  switch (ps) {
    case 0:
      // 从光标位置清除到可视窗口末尾
      final int maxRow = buffer.length;
      final int startRow = controller.currentPointer.y;
      for (int row = startRow; row < maxRow; row++) {
        // print('清除$row行');
        // 如果这个位置并没有字符
        int column;
        if (row == controller.currentPointer.y) {
          column = controller.currentPointer.x;
        } else {
          column = 0;
        }
        for (; column < controller.column; column++) {
          buffer.write(row, column, null);
        }
      }
      break;
    case 1:
      // 从可视窗口开始清除到光标位置
      final int startRow = buffer.position;
      final int maxRow = controller.currentPointer.y + 1;
      for (int row = startRow; row < maxRow; row++) {
        int maxColumn;
        if (row == controller.currentPointer.y) {
          maxColumn = controller.currentPointer.x;
        } else {
          maxColumn = controller.column;
        }
        for (int column = 0; column < maxColumn; column++) {
          buffer.write(row, column, null);
        }
      }
      break;
    case 2:
      // print('清空可视窗口 ${controller.startLine} ${controller.rowLength}');
      // 从视图左上角清除到视图右下角
      final int startRow = buffer.position;
      final int maxRow = controller.currentPointer.y + 1;
      for (int row = startRow; row < maxRow; row++) {
        // print('删除 $row 行');
        for (int column = 0; column < controller.column; column++) {
          // 如果这个位置并没有字符
          buffer.write(row, column, null);
        }
      }
      break;
    case 3:
      // TODO
      break;
    default:
  }
}

void eraseInLine(TermareController controller, String sequence) {
  /// K EL Erase In Line
  /// 0	Erase from the cursor through the end of the row.
  /// 1	Erase from the beginning of the line through the cursor.
  /// 2	Erase complete line.

  final Buffer buffer = controller.currentBuffer;
  sequence = sequence.replaceAll('?', '');
  int ps = int.tryParse(sequence);
  ps ??= 0;
  print('ps ->$ps');
  // 删除字符
  switch (ps) {
    case 0:
      // 从光标位置清除到行末尾
      final int startColumn = controller.currentPointer.x;
      final int endColumn = controller.column;
      for (int column = startColumn; column < endColumn; column++) {
        buffer.write(controller.currentPointer.y, column, null);
      }
      break;
    case 1:
      // 从行首清除到光标的位置
      const int startColumn = 0;
      final int endColumn = controller.currentPointer.x;
      for (int column = startColumn; column < endColumn; column++) {
        buffer.write(controller.currentPointer.y, column, null);
      }
      break;
    case 2:
      // 清除整行
      earseOneLine(controller, buffer);
      break;
    default:
  }
}

void insertLine(TermareController controller, String sequence) {
  /// L IL Insert Line
  /// 在当前光标的位置插入空白行
  /// 对于滚动顶部的每一行插入，滚动底部的每一行都将被删除。光标设置在第一列。如果光标在滚动边距之外，则IL无效。

  final Buffer buffer = controller.currentBuffer;
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(1);
  for (int i = 0; i < ps; i++) {
    controller.moveToRelativeRow(1);
    earseOneLine(controller, buffer);
  }
  controller.moveToLineFirstPosition();
  // TODO 没有完全验证
}

void deleteLine(TermareController controller, String sequence) {
  /// M DL Delete Line
  /// 删除活动的行
}

void deleteCharacter(TermareController controller, String sequence) {
  /// P DCH	Delete Character
  /// 删除字符后，光标和右边距之间的其余字符将向左移动。角色属性随角色一起移动。终端在右边距添加空白字符。
  /// vscode与macos原生终端均未发现删除效果
  final Buffer buffer = controller.currentBuffer;
  int ps = int.tryParse(sequence);
  ps ??= 1;
  print('ps:$ps');

  for (int column = 0; column < ps; column++) {
    Character character = buffer.getCharacter(
      controller.currentPointer.y,
      controller.currentPointer.x,
    );
    // print('删除 ${controller.currentPointer} 字符 ${character?.content} ');
    buffer.write(
      controller.currentPointer.y,
      controller.currentPointer.x,
      null,
    );
    final int startColumn = controller.currentPointer.x;
    final int endColumn = controller.column;
    for (int column = startColumn; column < endColumn; column++) {
      final Character character = buffer.getCharacter(
        controller.currentPointer.y,
        column + 1,
      );
      buffer.write(controller.currentPointer.y, column, character);
    }
  }
}

void scrollUp(TermareController controller, String sequence) {
  /// S SU Scroll Up
  /// Scroll Ps lines up
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(ps);
}

void scrollDown(TermareController controller, String sequence) {
  /// T SD Scroll Down
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(-ps);
}

void eraseCharacter(TermareController controller, String sequence) {
  /// X ECH	Erase Character

  final Buffer buffer = controller.currentBuffer;
  int ps = int.tryParse(sequence);
  ps ??= 1;
  final int startColumn = controller.currentPointer.x;
  final int endColumn = startColumn + ps;
  for (int column = startColumn; column < endColumn; column++) {
    // 如果这个一行都没有字符
    buffer.write(controller.currentPointer.y, column, null);
  }
}

void cursorBackwardTabulation(TermareController controller, String sequence) {
  /// Z CBT	Cursor Backward Tabulation
  int ps = int.tryParse(sequence);
  ps ??= 1;
  print(ps);
  controller.moveToRelativeColumn(-ps * 5);
}

void horizontalPositionAbsolute(TermareController controller, String sequence) {
  /// ` HPA	Horizontal Position Absolute
  /// Same as CHA.
  sequence = sequence.replaceAll('`', 'G');
  cursorHorizontalAbsolute(controller, sequence);
}

void horizontalPositionRelative(TermareController controller, String sequence) {
  /// a HPR	Horizontal Position Relative
  /// Same as CUF.
  sequence = sequence.replaceAll('a', 'C');
  cursorForward(controller, sequence);
}

void repeatPrecedingCharacter(TermareController controller, String sequence) {
  /// b REP	Repeat Preceding Character
  /// 重复前面的字符 ps 次数

  final Buffer buffer = controller.currentBuffer;
  int ps = int.tryParse(sequence);
  ps ??= 1;
  print(ps);
  final Position position = controller.currentPointer;
  final int row = position.y;
  final int column = max(position.x - ps, 0);
  final String data = buffer.getCharacter(row, column).content;
  // print('data ->${data * 3}');
  controller.write(data * ps);
}

void primaryDeviceAttributes(TermareController controller, String sequence) {
  /// c DA1	Primary Device Attributes
  /// 没弄明白干嘛的
}

void verticalPositionAbsolute(TermareController controller, String sequence) {
  /// d VPA	Vertical Position Absolute
  /// 移动光标到垂直的绝对位置
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToAbsoluteRow(ps);
}

void verticalPositionRelative(TermareController controller, String sequence) {
  /// e VPR	Vertical Position Relative
  /// 移动光标到垂直的相对位置
  int ps = int.tryParse(sequence);
  ps ??= 1;
  controller.moveToRelativeRow(ps);
}

void horizontalandVerticalPosition(
    TermareController controller, String sequence) {
  /// f HVP	Horizontal and Vertical Position
  /// Same as CUP.
  /// 将光标设置到指定位置
  sequence = sequence.replaceAll('f', 'H');
  cursorPosition(controller, sequence);
}

void tabClear(TermareController controller, String sequence) {
  /// g TBC	Tab Clear
  /// 清除tab
  /// 不知道实现
}

void setMode(TermareController controller, String sequence) {
  /// h SM Set Mode
  /// 设置终端模式
  /// 未实现
  if (sequence.startsWith('?')) {
    sequence = sequence.replaceAll('?', '');
    switch (sequence) {
      case '25':
        controller.showCursor = true;
        break;
      case '1049':
        controller.switchBufferToAlternate();
        controller.saveCursor();
        break;
      default:
    }
    // TODO 还有很多没写
  }
}

void dECPrivateSetMode() {
  /// DECSET	DEC Private Set Mode
  /// CSI ? Pm h
}

void resetMode(TermareController controller, String sequence) {
  /// l & ?l
  /// 设置终端模式
  /// 未实现
  if (sequence.startsWith('?')) {
    /// ?l DECRST	DEC Private Reset Mode
    sequence = sequence.replaceAll('?', '');
    switch (sequence) {
      case '25':
        controller.showCursor = false;

        /// 隐藏光标
        ///
        break;
      case '1049':
        controller.switchBufferToMain();
        controller.restoreCursor();
        break;
      default:
    }
    // TODO 还有很多没写
  }
}

void dECPrivateResetMode() {
  /// CSI ? Pm l
  /// DEC Private Reset Mode
}

void selectGraphicRendition(TermareController controller, String sequence) {
  /// CSI Pm m
  /// SGR Select Graphic Rendition
  /// 设置颜色属性
  // log('$blue Select Graphic Rendition -> $curSeq');
  if (sequence.isEmpty) {
    controller.textAttributes = TextAttributes.normal();
  } else {
    controller.textAttributes = controller.textAttributes.copyWith(
      sequence,
    );
  }
}

void deviceStatusReport(TermareController controller, String sequence) {
  /// CSI Ps n
  /// DSR	Device Status Report
  /// ?n DECDSR	DEC Device Status Report
  /// 未实现
}

void softTerminalReset(TermareController controller, String sequence) {
  /// CSI ! p
  /// DECSTR Soft Terminal Reset
  /// 设置终端所有属性到初始状态
}

void setCursorStyle(TermareController controller, String sequence) {
  /// CSI Ps SP q
  /// DECSCUSR Set Cursor Style
  /// 设置光标属性
}

void setTopandBottomMargin(TermareController controller, String sequence) {
  /// CSI Ps ; Ps r
  /// DECSTBM	Set Top and Bottom Margin
  if (sequence.isEmpty) {
    sequence = '0;${controller.row}';
  }
  final int row = int.parse(sequence.split(';')[1]);

  controller.currentBuffer.setViewPoint(row);
}

void saveCursor(TermareController controller, String sequence) {
  /// CSI s
  ///
  /// s SCOSC	Save Cursor
  controller.tmpPointer = controller.currentPointer;
  controller.tmpTextAttributes = controller.textAttributes;
}

void restoreCursor(TermareController controller, String sequence) {
  /// CSI u
  /// SCORC	Restore Cursor
  controller.currentPointer = controller.tmpPointer;
  controller.textAttributes = controller.tmpTextAttributes;
}

void insertColumns(TermareController controller, String sequence) {
  /// CSI Ps ' }
  /// DECIC	Insert Columns
  ///
}

void deleteColumns(TermareController controller, String sequence) {
  /// CSI Ps ' ~
  /// DECIC	Delete Columns
  ///
}

class Csi {
  Csi._();
  static String sequence = '';
  static void handle(TermareController controller, List<int> utf8CodeUnits) {
    final String currentChar = utf8.decode(utf8CodeUnits);
    if (csiSeqHandlerMap.containsKey(currentChar)) {
      print('curSeq -> $sequence$currentChar');
      final CsiHandler handler = csiSeqHandlerMap[currentChar];
      // 执行此次序列
      // 执行完清空
      handler(controller, sequence);
      sequence = '';
      controller.csiStart = false;
    } else {
      sequence += currentChar;
    }
  }

  static void log(Object object) {
    if (!kReleaseMode) {
      print(object);
    }
  }
}

void earseOneLine(TermareController controller, Buffer buffer) {
  const int startColumn = 0;
  final int endColumn = controller.row;
  for (int column = startColumn; column < endColumn; column++) {
    buffer.write(controller.currentPointer.y, column, null);
  }
}
