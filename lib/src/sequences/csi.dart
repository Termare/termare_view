import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:termare_view/src/model/text_attributes.dart';
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
    final String currentChar = utf8.decode(utf8CodeUnits);
    // print('curSeq -> ${curSeq.isEmpty}');
    // print(csiSeqChars.indexOf('K'));
    if (csiSeqChars.contains(currentChar)) {
      // print('curSeq -> ${curSeq}$currentChar');
      // 执行此次序列
      // 执行完清空
      // print('curSeq -> $curSeq');
      if (currentChar == csiSeqChars[0]) {
        // @
        // print('curSeq -> $curSeq');
        // if (curSeq.contains('SP')) {
        //   final int ps = int.tryParse(curSeq);
        //   print('ps -> 应该向左移动$ps');
        //   print('curSeq -> $curSeq');
        // } else {
        final int ps = int.tryParse(curSeq);
        print('ps -> $ps');
        for (int i = 0; i < ps; i++) {
          controller.writeChar(' ');
        }
        print('curSeq -> $curSeq');
        // }
        //
      } else if (currentChar == csiSeqChars[1]) {
        // A
        controller.log('$blue CSI Cursor Up');
        print('curSeq -> ${curSeq}');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.currentPointer = Position(
          controller.currentPointer.x,
          controller.currentPointer.y - ps,
        );
      } else if (currentChar == csiSeqChars[2]) {
        // B
        controller.log('$blue CSI Cursor Down');
        print('curSeq -> ${curSeq}');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.currentPointer = Position(
          controller.currentPointer.x,
          controller.currentPointer.y + ps,
        );
      } else if (currentChar == csiSeqChars[3]) {
        // C
        controller.log('$blue CSI Cursor Down');
        print('curSeq -> ${curSeq}');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.moveToPosition(ps);
      } else if (currentChar == csiSeqChars[4]) {
        // D
        controller.log('$blue CSI Cursor Down');
        print('curSeq -> $curSeq');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        if (ps < 100) {
          controller.moveToPosition(-ps);
        }
      } else if (currentChar == csiSeqChars[5]) {
        controller.log('$blue CSI Cursor Down');
        print('curSeq -> ${curSeq}');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.currentPointer = Position(
          controller.currentPointer.x,
          controller.currentPointer.y + ps,
        );
        controller.moveToLineFirstPosition();
      } else if (currentChar == csiSeqChars[6]) {
        controller.log('$blue CSI Cursor Down');
        print('curSeq -> ${curSeq}');

        int ps = int.tryParse(curSeq);
        ps ??= 1;
        print('ps -> $ps');
        controller.currentPointer = Position(
          controller.currentPointer.x,
          controller.currentPointer.y - ps,
        );
        controller.moveToLineFirstPosition();
      } else if (currentChar == csiSeqChars[7]) {
        int ps = int.tryParse(curSeq);
        ps ??= 1;
        // 	Cursor Horizontal Absolute
        controller.currentPointer = Position(
          ps - 1,
          controller.currentPointer.y,
        );
        print('Cursor Horizontal Absolute ps=$ps');
      } else if (currentChar == csiSeqChars[8]) {
        print('curSeq ->$curSeq<-');
        print(curSeq == 'H');
        if (currentChar == 'H' && curSeq.isEmpty) {
          // 说明是esc [H
          // 如果设置了原始模式，则将光标置于滚动边距内的绝对位置。
          // 如果未设置ORIGIN模式，请将光标置于视口内的绝对位置。
          // 请注意，坐标是从1开始的，因此左上角的位置从开始1 ; 1。
          controller.currentPointer = Position(0, controller.startLine);
          print(controller.currentPointer);
        }
        print('Cursor Position ${controller.startLine}');
      } else if (currentChar == csiSeqChars[9]) {
      } else if (currentChar == csiSeqChars[10]) {
        // TODO
        // J
        // controller.log(
        //   '$blue CSI ED Erase In Display -> $curSeq  cache.length -> ${controller.cache.length}',
        // );
        int ps = int.tryParse(curSeq);
        ps ??= 0;
        switch (ps) {
          case 0:
            // 从光标位置清除到可视窗口末尾
            for (int r = controller.currentPointer.y;
                r < controller.startLine + controller.rowLength;
                r++) {
              // 如果这个位置并没有字符
              for (int c = 0; c < controller.columnLength; c++) {
                // print('$r $c');
                // 如果这个位置并没有字符
                if (controller.cache[r] == null) {
                  continue;
                } else {
                  controller.cache[r][c] = null;
                }
              }
            }
            break;
          case 2:
            print('清空可视窗口 ${controller.startLine} ${controller.rowLength}');
            // 从视图左上角清除到视图右下角
            for (int r = controller.startLine;
                r < controller.startLine + controller.rowLength;
                r++) {
              // 如果这个位置并没有字符
              for (int c = 0; c < controller.columnLength; c++) {
                // print('$r $c');
                // 如果这个位置并没有字符
                if (controller.cache[r] == null) {
                  continue;
                } else {
                  controller.cache[r][c] = null;
                }
              }
            }
            break;
          default:
        }
      } else if (currentChar == csiSeqChars[11]) {
        // 'K'
        int ps = int.tryParse(curSeq);
        ps ??= 0;
        print('ps ->$ps');
        // 删除字符
        switch (ps) {
          case 0:
            for (int c = controller.currentPointer.x;
                c < controller.columnLength;
                c++) {
              // 如果这个位置并没有字符
              if (controller.cache[controller.currentPointer.y] == null) {
                return true;
              } else {
                controller.cache[controller.currentPointer.y][c] = null;
              }
            }
            break;
          case 1:
            for (int c = 0; c < controller.currentPointer.x; c++) {
              // 如果这个位置并没有字符
              if (controller.cache[controller.currentPointer.y] == null) {
                return true;
              } else {
                controller.cache[controller.currentPointer.y][c] = null;
              }
            }
            break;
          case 2:
            for (int c = 0; c < controller.columnLength; c++) {
              // 如果这个位置并没有字符
              if (controller.cache[controller.currentPointer.y] == null) {
                return true;
              } else {
                controller.cache[controller.currentPointer.y][c] = null;
              }
            }
            break;
          default:
        }
        // 可能存在光标的位置在最后一行的开始，但是开始那一行并没有任何的字符，例如cache.length为10，光标在11行的第一个格子
      } else if (currentChar == csiSeqChars[12]) {
      } else if (currentChar == csiSeqChars[13]) {
      } else if (currentChar == csiSeqChars[14]) {
      } else if (currentChar == csiSeqChars[15]) {
      } else if (currentChar == csiSeqChars[16]) {
      } else if (currentChar == csiSeqChars[17]) {
      } else if (currentChar == csiSeqChars[18]) {
      } else if (currentChar == csiSeqChars[19]) {
      } else if (currentChar == csiSeqChars[20]) {
      } else if (currentChar == csiSeqChars[21]) {
      } else if (currentChar == csiSeqChars[22]) {
      } else if (currentChar == csiSeqChars[23]) {
      } else if (currentChar == csiSeqChars[24]) {
      } else if (currentChar == csiSeqChars[25]) {
        // TODO不准确
        // f
        // print('Horizontal and Vertical Position curSer->$curSeq')
        // log('$blue CSI : CUP Cursor Position -> $header');
        controller.currentPointer = Position(
          int.tryParse(curSeq.split(';')[1]),
          int.tryParse(curSeq.split(';')[0]) - 1 + controller.startLine,
        );
      } else if (currentChar == csiSeqChars[26]) {
      } else if (currentChar == csiSeqChars[27]) {
      } else if (currentChar == csiSeqChars[28]) {
      } else if (currentChar == csiSeqChars[29]) {
        // m
        // log('$blue Select Graphic Rendition -> $curSeq');
        if (curSeq.isEmpty) {
          controller.textAttributes = TextAttributes.normal();
        } else {
          controller.textAttributes = controller.textAttributes.copyWith(
            curSeq,
          );
        }
        // log('$blue ${controller.textAttributes}');
      } else if (currentChar == csiSeqChars[30]) {
      } else if (currentChar == csiSeqChars[31]) {
      } else if (currentChar == csiSeqChars[32]) {
      } else if (currentChar == csiSeqChars[33]) {
      } else if (currentChar == csiSeqChars[34]) {
      } else if (currentChar == csiSeqChars[35]) {
      } else if (currentChar == csiSeqChars[36]) {
      } else if (currentChar == csiSeqChars[37]) {
      } else if (currentChar == csiSeqChars[38]) {}

//           if (data[i] == '?') {
//             csiAnd3fStart = true;
//             continue;
//           }
//           final int charWordindex =
//               data.substring(i).indexOf(RegExp('[A-Za-z]'));
//           if (charWordindex == -1) {
//             continue;
//           }
//           String header = '';
//           header = data.substring(i, i + charWordindex);

//           final String sequenceChar = data.substring(i)[charWordindex];

//           // log('line.substring($i)->${data.substring(i).split('\n').first}');
//           if (sequenceChar == 'r') {
//             log('$blue CSI Set Top and Bottom Margin -> $header');
//             // log('\ header -> $header');
//             i += header.length;
//           }

      curSeq = '';
      controller.csiStart = false;
    } else {
      curSeq += currentChar;
    }
  }

  static void log(Object object) {
    if (!kReleaseMode) {
      print(object);
    }
  }
}
