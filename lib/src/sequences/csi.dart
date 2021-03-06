import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/core/letter_eneity.dart';
import 'package:termare_view/src/core/text_attributes.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/termare_view.dart';

bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
List<String> csiSeqChars = [
  '@', //0
  'A', //1
  'B', //2
  'C', //3
  'D', //4
  'E', //5
  'F', //6
  'G', //7
  'H', //8
  'I', //9
  'J', //10
  'K', //11
  'L', //12
  'M', //13
  'P', //14
  'S', //15
  'T', //16
  'X', //17
  'Z', //18
  '`', //19
  'a', //20
  'b', //21
  'c', //22
  'd', //23
  'e', //24
  'f', //25
  'g', //26
  'h', //27
  'l', //28
  'm', //29
  'n', //30
  'p', //31
  'q', //32
  'r', //33
  's', //34
  'u', //35
  '}', //36
  '~', //37
];

class Csi {
  static String curSeq = '';
  static bool handle(TermareController controller, List<int> utf8CodeUnits) {
    Buffer buffer = controller.buffer;
    final String currentChar = utf8.decode(utf8CodeUnits);
    if (csiSeqChars.contains(currentChar)) {
      print('curSeq -> $curSeq$currentChar');
      // 执行此次序列
      // 执行完清空
      if (currentChar == csiSeqChars[0]) {
        /// @ ICH Insert Characters
        /// 向当前所在的位置添加一个空白字符
        /// ICH序列插入Ps空白字符。光标停留在空白字符的开头。光标和右边距之间的文本向右移动。超过右边距的字符将丢失。
        /// 还有点问题，下次记得找一下实际用到的序列
        //TODO
        final int ps = int.tryParse(curSeq);
        for (int i = 0; i < ps; i++) {
          final int startColumn = controller.currentPointer.x;
          // print('startColumn $startColumn');
          final int endColumn = controller.column;
          for (int c = endColumn; c > startColumn; c--) {
            String source = buffer
                .getCharacter(controller.currentPointer.y, c - 1)
                ?.content;
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
      } else if (currentChar == csiSeqChars[1]) {
        // A CUU
        /// 向上移动光标
        controller.log('$blue CSI Cursor Up');
        int ps = int.tryParse(curSeq);

        /// ps 默认为1
        ps ??= 1;
        controller.moveToRelativeRow(-ps);
      } else if (currentChar == csiSeqChars[2]) {
        // B CUD
        /// 向下移动光标
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(ps);
      } else if (currentChar == csiSeqChars[3]) {
        // C CUF
        /// 向前移动光标
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToPosition(ps);
      } else if (currentChar == csiSeqChars[4]) {
        // D CUB
        /// 向后移动光标
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        if (ps < 100) {
          /// 有的时候会有 999999D，例如在执行 neofetch 的时候会用到这个序列
          /// 但实际移动不了那么多
          controller.moveToPosition(-ps);
        }
      } else if (currentChar == csiSeqChars[5]) {
        /// E CNL
        /// 跟 CUD 差不多，另外需要将光标移动到第一行
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.moveToRelativeRow(ps);
        controller.moveToLineFirstPosition();
      } else if (currentChar == csiSeqChars[6]) {
        /// F CPL Cursor Backward
        /// 跟 CUU 差不多，另外需要将光标移动到第一行
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(-ps);
        controller.moveToLineFirstPosition();
      } else if (currentChar == csiSeqChars[7]) {
        /// G CHA	Cursor Horizontal Absolute
        /// 将光标移动到绝对定位列
        print('将光标移动到绝对定位列');
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToAbsoluteColumn(ps);
        // print('Cursor Horizontal Absolute ps=$ps');
      } else if (currentChar == csiSeqChars[8]) {
        print(' H CUP	Cursor Position');

        /// H CUP	Cursor Position
        /// 将光标设置到位置: [Ps, Ps]
        /// [1,1]代表左上角
        // 说明是esc [H
        // 如果设置了原始模式，则将光标置于滚动边距内的绝对位置。
        // 如果未设置ORIGIN模式，请将光标置于视口内的绝对位置。
        // 请注意，坐标是从1开始的，因此左上角的位置从开始1 ; 1。
        /// TODO ORIGIN模式
        if (curSeq.isEmpty) {
          curSeq = '1;1';
        }
        final int row = int.parse(curSeq.split(';')[0]);
        final int column = int.parse(curSeq.split(';')[1]);
        print('row $row column $column');
        controller.moveToOffset(column, row);
        print('${controller.currentPointer}');
      } else if (currentChar == csiSeqChars[9]) {
        /// I CHT	Cursor Horizontal Tabulation
        /// 光标向右移动 ps 个 tab 的位置
        /// 这里自己测出 tab 在终端的位置有5个终端字符
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToPosition(ps * 5);
      } else if (currentChar == csiSeqChars[10]) {
        /// J DECSED	Selective Erase In Display
        /// 清空显示的字符
        /// 0	Erase from the cursor through the end of the viewport.
        /// 1	Erase from the beginning of the viewport through the cursor.
        /// 2	Erase complete viewport.
        /// 3	Erase scrollback.
        curSeq = curSeq.replaceAll('?', '');
        int ps = int.tryParse(curSeq);
        ps ??= 0;
        print('ps $ps');
        switch (ps) {
          case 0:
            // 从光标位置清除到可视窗口末尾
            final int maxRow = controller.row;
            final int startRow = controller.currentPointer.y;
            for (int row = startRow; row < maxRow; row++) {
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
            final int maxRow = controller.currentPointer.y + 1;
            final int startRow = 0;
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
            final int maxRow = controller.row;
            final int startRow = 0;
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
      } else if (currentChar == csiSeqChars[11]) {
        /// K EL	Erase In Line
        /// 0	Erase from the cursor through the end of the row.
        /// 1	Erase from the beginning of the line through the cursor.
        /// 2	Erase complete line.
        curSeq = curSeq.replaceAll('?', '');
        int ps = int.tryParse(curSeq);
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
      } else if (currentChar == csiSeqChars[12]) {
        /// IL	Insert Line	CSI Ps L
        /// 在当前光标的位置插入空白行
        /// 对于滚动顶部的每一行插入，滚动底部的每一行都将被删除。光标设置在第一列。如果光标在滚动边距之外，则IL无效。

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(1);
        for (int i = 0; i < ps; i++) {
          controller.moveToRelativeRow(1);
          earseOneLine(controller, buffer);
        }
        controller.moveToLineFirstPosition();
        // TODO 没有完全验证
      } else if (currentChar == csiSeqChars[13]) {
        /// M DL	Delete Line
        /// 删除活动的行
      } else if (currentChar == csiSeqChars[14]) {
        /// P DCH	Delete Character
        /// 删除字符后，光标和右边距之间的其余字符将向左移动。角色属性随角色一起移动。终端在右边距添加空白字符。
        /// vscode与macos原生终端均未发现删除效果
        int ps = int.tryParse(curSeq);
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
      } else if (currentChar == csiSeqChars[15]) {
        /// S SU	Scroll Up
        /// Scroll Ps lines up
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(ps);
      } else if (currentChar == csiSeqChars[16]) {
        /// T SD Scroll Down
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(-ps);
      } else if (currentChar == csiSeqChars[17]) {
        /// X ECH	Erase Character
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        final int startColumn = controller.currentPointer.x;
        final int endColumn = startColumn + ps;
        for (int column = startColumn; column < endColumn; column++) {
          // 如果这个一行都没有字符
          buffer.write(controller.currentPointer.y, column, null);
        }
      } else if (currentChar == csiSeqChars[18]) {
        /// Z CBT	Cursor Backward Tabulation
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print(ps);
        controller.moveToRelativeColumn(-ps * 5);
      } else if (currentChar == csiSeqChars[19]) {
        /// ` HPA	Horizontal Position Absolute
        /// Same as CHA.
        curSeq = curSeq.replaceAll('`', 'G');
        handle(controller, utf8.encode('G'));
      } else if (currentChar == csiSeqChars[20]) {
        /// a HPR	Horizontal Position Relative
        curSeq = curSeq.replaceAll('a', 'C');
        handle(controller, utf8.encode('C'));
      } else if (currentChar == csiSeqChars[21]) {
        /// b REP	Repeat Preceding Character
        /// 重复前面的字符 ps 次数
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print(ps);
        final Position position = controller.currentPointer;
        final int row = position.y;
        final int column = max(position.x - ps, 0);
        final String data = buffer.getCharacter(row, column).content;
        // print('data ->${data * 3}');
        controller.write(data * ps);
      } else if (currentChar == csiSeqChars[22]) {
        /// c DA1	Primary Device Attributes
        /// 没弄明白干嘛的
      } else if (currentChar == csiSeqChars[23]) {
        /// d VPA	Vertical Position Absolute
        /// 移动光标到垂直的绝对位置
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToAbsoluteRow(ps);
      } else if (currentChar == csiSeqChars[24]) {
        /// e VPR	Vertical Position Relative
        /// 移动光标到垂直的相对位置
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        controller.moveToRelativeRow(ps);
      } else if (currentChar == csiSeqChars[25]) {
        /// f HVP	Horizontal and Vertical Position
        /// CUP
        /// 将光标设置到指定位置
        curSeq = curSeq.replaceAll('f', 'H');
        handle(controller, utf8.encode('H'));
      } else if (currentChar == csiSeqChars[26]) {
        /// g TBC	Tab Clear
        /// 清除tab
        /// 不知道实现
      } else if (currentChar == csiSeqChars[27]) {
        /// h SM	Set Mode
        /// 设置终端模式
        /// 未实现
        if (curSeq.startsWith('?')) {
          print('object');
          curSeq = curSeq.replaceAll('?', '');
          switch (curSeq) {
            case '25':
              controller.showCursor = true;
              break;
            default:
          }
          // TODO 还有很多没写
        }
      } else if (currentChar == csiSeqChars[28]) {
        /// l & ?l
        /// 设置终端模式
        /// 未实现
        if (curSeq.startsWith('?')) {
          /// ?l DECRST	DEC Private Reset Mode
          curSeq = curSeq.replaceAll('?', '');
          switch (curSeq) {
            case '25':
              controller.showCursor = false;

              /// 隐藏光标
              ///
              break;
            default:
          }
          // TODO 还有很多没写
        }
      } else if (currentChar == csiSeqChars[29]) {
        // m SGR	Select Graphic Rendition
        /// 设置颜色属性
        // log('$blue Select Graphic Rendition -> $curSeq');
        if (curSeq.isEmpty) {
          controller.textAttributes = TextAttributes.normal();
        } else {
          controller.textAttributes = controller.textAttributes.copyWith(
            curSeq,
          );
        }
      } else if (currentChar == csiSeqChars[30]) {
        /// n DSR	Device Status Report
        /// ?n DECDSR	DEC Device Status Report
        /// 未实现
      } else if (currentChar == csiSeqChars[31]) {
        ///p DECSTR	Soft Terminal Reset
        /// 设置终端所有属性到初始状态
      } else if (currentChar == csiSeqChars[32]) {
        /// q DECSCUSR	Set Cursor Style
        /// 设置光标属性
      } else if (currentChar == csiSeqChars[33]) {
        /// r DECSTBM	Set Top and Bottom Margin
      } else if (currentChar == csiSeqChars[34]) {
        /// s SCOSC	Save Cursor
        controller.tmpPointer = controller.currentPointer;
        controller.tmpTextAttributes = controller.textAttributes;
      } else if (currentChar == csiSeqChars[35]) {
        /// u SCORC	Restore Cursor
        controller.currentPointer = controller.tmpPointer;
        controller.textAttributes = controller.tmpTextAttributes;
      } else if (currentChar == csiSeqChars[36]) {
        ///
      } else if (currentChar == csiSeqChars[37]) {}
      curSeq = '';
      controller.csiStart = false;
    } else {
      curSeq += currentChar;
    }
  }

  static void earseOneLine(TermareController controller, Buffer buffer) {
    const int startColumn = 0;
    final int endColumn = controller.row;
    for (int column = startColumn; column < endColumn; column++) {
      buffer.write(controller.currentPointer.y, column, null);
    }
  }

  static void log(Object object) {
    if (!kReleaseMode) {
      print(object);
    }
  }
}
