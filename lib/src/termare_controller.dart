import 'dart:convert';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/src/painter/model/position.dart';

import 'core/safe_list.dart';
import 'model/letter_eneity.dart';
import 'observable.dart';
import 'painter/termare_painter.dart';
import 'theme/term_theme.dart';
import 'utils/keyboard_handler.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
String red = '\x1b[31m';
String pink = '\x1b[34m';

String blue = '\x1b[34m';
String whiteBackground = '\x1b[47m';
String defaultColor = '\x1b[0m';

class TermareController with Observable {
  TermareController({
    this.theme,
    this.rowLength = 57,
    this.columnLength = 41,
    this.showBackgroundLine = false,
    this.fontFamily = 'packages/termare_view/DroidSansMono',
  }) {
    theme ??= TermareStyles.termux;
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
  }
  final String fontFamily;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
  final int cacheLine = 1000;

  void Function() onBell;
  KeyboardInput keyboardInput;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  // String out = '';
  TermareStyle theme;
  SafeList<SafeList<LetterEntity>> cache = SafeList();
  bool showCursor = true;
  // 当从 pty 读出内容的时候就会自动滑动
  bool autoScroll = true;
  // 显示背景网格
  bool showBackgroundLine;

  int rowLength;
  int paddingBottom = 0;
  int columnLength;

  String fontColorTag = '0';
  String backgroundColorTag = '0';
  String fontStyleTag = '0';
  // 39 是 default
  String foregroundColor = '39';
  String backgroundColor = '49';
  // void write(String data) => unixPthC.write(data);

  /// 直接指向 pty write 函数
  void write(String data) {
    dirty = true;
    parseOutput(data);
    notifyListeners();
  }

  // 光标的位置；
  Position currentPointer = Position(0, 0);
  // 通过这个变量来滑动终端
  int startLine = 0;
  void clear() {
    cache = SafeList();
    currentPointer = Position(0, 0);
    dirty = true;
  }

  void moveToPosition(int x) {
    // 玄学勿碰
    final int n = currentPointer.y * columnLength + currentPointer.x;
    int target = n + x;
    if (target < 0) {
      target = 0;
    }
    currentPointer = Position(target % columnLength, target ~/ columnLength);
  }

  void setPtyWindowSize(Size size) {
    final int row = size.height ~/ theme.letterHeight;
    // 列数
    final int column = size.width ~/ theme.letterWidth;
    rowLength = row;
    columnLength = column;
    print('setPtyWindowSize $size $rowLength $columnLength');
    dirty = true;
    notifyListeners();
  }

  void setFontSize(double fontSize) {
    theme.fontSize = fontSize;
    final Size size = window.physicalSize;
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    setPtyWindowSize(Size(screenWidth, screenHeight));
    dirty = true;
    notifyListeners();
  }

  Position getToPosition(int x) {
    if (currentPointer.x + x >= columnLength) {
      // 说明在行首
      return Position(
        currentPointer.x + x - columnLength,
        currentPointer.y + 1,
      );
    } else if (currentPointer.x + x <= 0) {
      // 说明在行首
      return Position(
        columnLength - 1,
        currentPointer.y - 1,
      );
    } else {
      return Position(currentPointer.x + x, currentPointer.y);
    }
  }

  void moveToPrePosition() {
    moveToPosition(-1);
  }

  void moveToNextPosition() {
    moveToPosition(1);
  }

  void moveToNextLinePosition() {
    currentPointer = Position(currentPointer.x, currentPointer.y + 1);
  }

  void moveToLineFirstPosition() {
    currentPointer = Position(0, currentPointer.y);
  }

  // 不能放在 parseOutput 内部，可能存在一次流的末尾为终端序列的情况
  bool csiStart = false;
  bool oscStart = false;
  // 3f 是字符 ?
  bool csiAnd3fStart = false;
  bool escapeStart = false;
  bool dcsStart = false;
  void changeEntityStyle(String tag) {
    final int intTag = int.tryParse(tag);
    if (intTag == 0 || tag.isEmpty) {
      fontColorTag = '0';
      backgroundColorTag = '0';
      fontStyleTag = '0';
    }
    if (0 < intTag && intTag < 7) {
      fontStyleTag = tag;
    }
    if (8 <= intTag && intTag <= 15) {
      fontColorTag = tag;
      backgroundColorTag = tag;
    }
    if (30 <= intTag && intTag <= 37) {
      fontColorTag = tag;
    }
    // TODO 38前景色 48 背景色
    if (tag == '38') {
      foregroundColor = tag;
    }
    if (tag == '39') {
      foregroundColor = tag;
    }
    if (tag == '48') {
      backgroundColor = tag;
    }
    if (tag == '49') {
      backgroundColor = tag;
    }
    if (40 <= intTag && intTag <= 47) {
      backgroundColorTag = tag;
    }
  }

  void parseOutput(String data, {bool verbose = !kReleaseMode}) {
    print('$red $whiteBackground parseOutput->$data');
    print('$red $whiteBackground parseOutput->${utf8.encode(data)}');
    print('$red $whiteBackground parseOutput->${data.codeUnits}');
    for (int i = 0; i < data.length; i++) {
      if (i > data.length - 1) {
        break;
      }
      final List<int> codeUnits = data[i].codeUnits;
      // dart 的 codeUnits 是 utf32
      final List<int> utf8CodeUnits = utf8.encode(data[i]);
      // print('codeUnits->$codeUnits');
      // print('utf8CodeUnits->$utf8CodeUnits');
      // if (utf8CodeUnits.length == 1) {
      //   defaultStyle = defaultStyle.copyWith(
      //     fontFamily: 'packages/termare_view/DroidSansMono',
      //   );
      // } else {
      //   defaultStyle = defaultStyle.copyWith(
      //     fontFamily: 'packages/termare_view/DroidSansMono',
      //   );
      // }
      if (utf8CodeUnits.length == 1) {
        // 说明单字节
        /// ------------------------------- c0 --------------------------------
        /// 考虑过用switch case，但是用了eq这个加强判断的库
        if (csiAnd3fStart) {
          csiAnd3fStart = false;
          final int charWordindex = data.substring(i).indexOf(RegExp('[a-z]'));
          print('line.substring($i)->${data.substring(i).split('\n').first}');
          String header = '';
          header = data.substring(i, i + charWordindex);
          final String sequenceChar = data.substring(i)[charWordindex];
          if (sequenceChar == 'l') {
            header.split(';').forEach((element) {
              print('ESC[?l序列 $element');
              if (element == '25') {
                showCursor = false;
              }
            });
          }
          if (sequenceChar == 'h') {
            header.split(';').forEach((element) {
              print('ESC[?h序列 $element');
              if (element == '25') {
                showCursor = true;
              }
            });
          }
          print('header->$header');

          i += header.length;
          continue;
        }
        if (oscStart) {
          // TODO 有三种，没写完
          oscStart = false;
          if (verbose) {
            print('$red Set window title and icon name');
          }
          // print('line.substring($i)->${data.substring(i).split('\n').first}');
          final int charWordindex = data.substring(i).indexOf(
                String.fromCharCode(7),
              );
          if (charWordindex == -1) {
            continue;
          }
          String header = '';
          header = data.substring(i, i + charWordindex);
          print('osc -> $header\a');
          i += header.length;
          continue;
        }
        if (csiStart) {
          csiStart = false;
          if (data[i] == 'K') {
            // 删除字符
            // 可能存在光标的位置在最后一行的开始，但是开始那一行并没有任何的字符，所例如cache.length为10，光标在11行的第一个格子
            for (int c = currentPointer.x; c < columnLength; c++) {
              if (cache[currentPointer.y] == null) {
                continue;
              }
              cache[currentPointer.y][c] = null;
            }
            // TODO 拿来测试

            // print(cache[currentPointer.y][currentPointer.x - 1].content);
            // final TextPainter painter = painterCache.getOrPerformLayout(
            //   TextSpan(
            //     text: ' ',
            //     style: defaultStyle,
            //   ),
            // );
            // cache[currentPointer.y][currentPointer.x] = LetterEntity(
            //   content: ' ',
            //   letterWidth: painter.width,
            //   letterHeight: painter.height,
            //   position: currentPointer,
            //   textStyle: defaultStyle.copyWith(fontSize: theme.fontSize),
            // );
            continue;
          }
          if (data[i] == '?') {
            csiAnd3fStart = true;
            continue;
          }
          final int charWordindex =
              data.substring(i).indexOf(RegExp('[A-Za-z]'));
          if (charWordindex == -1) {
            continue;
          }
          String header = '';
          header = data.substring(i, i + charWordindex);

          final String sequenceChar = data.substring(i)[charWordindex];
          if (sequenceChar == 'm') {
            // print('ESC[ pm m header -> $header');

            if (header.isEmpty) {
              changeEntityStyle('0');
            } else {
              header.split(';').forEach((element) {
                // print('ESC[ pm m header element -> $element');
                changeEntityStyle(element);
              });
            }
            i += header.length;
          }
          // print('line.substring($i)->${data.substring(i).split('\n').first}');
          if (sequenceChar == 'r') {
            print('$blue CSI Set Top and Bottom Margin -> $header');
            // print('\ header -> $header');
            i += header.length;
          }
          if (sequenceChar == 'C') {
            print('ESC[ ps C header -> $header');
            moveToPosition(int.tryParse(header));
            // header.split(';').forEach((element) {
            //   defaultStyle = getTextStyle(element, defaultStyle);
            // });
            i += header.length;
          }
          if (sequenceChar == 'A') {
            print('$blue CSI Cursor Up');
            // print('ESC[ ps A header -> $header');
            currentPointer = Position(
              currentPointer.x,
              currentPointer.y - int.tryParse(header),
            );
            i += header.length;
          }
          if (sequenceChar == 'J') {
            print(
                'ED	Erase In Display -> $header $currentPointer ${cache.length}');
            for (int r = currentPointer.y; r < cache.length; r++) {
              for (int c = currentPointer.x; c < columnLength + 1; c++) {
                cache[r][c] = null;
              }
            }
            // i += header.length;
          }
          if (sequenceChar == 'f') {
            print('CUP	Cursor Position -> $header');
            currentPointer = Position(
              int.tryParse(header.split(';')[1]),
              int.tryParse(header.split(';')[0]) - 1 - startLine,
            );
            i += header.length;
          }
          if (sequenceChar == 'D') {
            print('ESC[ ps D header -> $header');
            final int backStep = int.tryParse(header);
            if (backStep < 100) {
              moveToPosition(-backStep);
            }
            i += header.length;
          }
          if (sequenceChar == 'B') {
            print('ESC[ ps D header -> $header');
            currentPointer = Position(
              currentPointer.x,
              currentPointer.y + int.tryParse(header),
            );
            i += header.length;
          }
          continue;
        }
        if (escapeStart) {
          escapeStart = false;
          if (eq(codeUnits, [0x5b])) {
            // ascii 91 是字符->[，‘esc [’开启了 csi 序列。
            csiStart = true;
          }
          if (eq(codeUnits, [0x5d])) {
            // ascii 93 是字符->]，‘esc ]’开启了 osc 序列。
            print('$red oscStart');
            oscStart = true;
          }
          continue;
        }
        if (eq(codeUnits, [0])) {
          if (verbose) {
            print('$red<- C0 NULL ->');
          }
          continue;
        } else if (eq(codeUnits, [0x07])) {
          onBell?.call();
          print('$red<- C0 Bell ->');
          continue;
        } else if (eq(codeUnits, [0x08])) {
          // 光标左移动
          if (verbose) {
            print('$red<- C0 Backspace ->');
          }
          moveToPrePosition();
          continue;
        } else if (eq(codeUnits, [0x09])) {
          moveToPosition(2);
          if (verbose) {
            print('$red<- C0 Horizontal Tabulation ->');
          }
          continue;
        } else if (eq(codeUnits, [0x0a]) ||
            eq(codeUnits, [0x0b]) ||
            eq(codeUnits, [0x0c])) {
          // TODO 有问题，应该是指向下移动光标才对
          moveToNextLinePosition();
          moveToLineFirstPosition();
          if (verbose) {
            // print('$red<- C0 Line Feed ->');
          }
          continue;
        } else if (eq(codeUnits, [0x0d])) {
          // ascii 13
          moveToLineFirstPosition();
          if (verbose) {
            print('$red<- C0 Carriage Return ->');
          }
          continue;
        } else if (eq(codeUnits, [0x0e])) {
          // TODO
          if (verbose) {
            print('$red<- C0 Shift Out ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0x0f])) {
          // TODO
          if (verbose) {
            print('$red<- C0 Shift In ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0x1b])) {
          if (verbose) {
            print('$red<- C0 Escape ->');
          }
          escapeStart = true;
          continue;
        }
      } else {
        // 双字节 0x84 在 utf8中一个字节是保存不下来的，按照utf8的编码规则，8位的第一位为1那么一定是两个字节
        // ，其中第一位需要拿来当符号位，但是dart是utf32，可以通过一个字节来解析
        if (eq(utf8CodeUnits, [0xc2, 0x84])) {
          // c1 序列
          moveToNextLinePosition();
          if (verbose) {
            print('$pink<- C1 Index ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x85])) {
          moveToNextLinePosition();
          moveToLineFirstPosition();
          if (verbose) {
            print('$pink<- C1 	Next Line ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x88])) {
          // moveToPosition(4);
          if (verbose) {
            print('$pink<- C1 Horizontal Tabulation Set ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x90])) {
          // Start of a DCS sequence.
          dcsStart = true;
          if (verbose) {
            print('$pink<- C1	Device Control String ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x9b])) {
          csiStart = true;
          // 	Start of a CSI sequence.
          if (verbose) {
            print('$pink<- C1 Control Sequence Introducer ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x9c])) {
          // TODO
          if (verbose) {
            print('$pink<- C1 String Terminator ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x9d])) {
          oscStart = true;
          if (verbose) {
            print('$pink<- C1 Operating System Command ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x9e])) {
          // TODO 不太清除实际的行为
          if (verbose) {
            print('$pink<- C1 Privacy Message ->');
          }
          continue;
        } else if (eq(utf8CodeUnits, [0xc2, 0x9f])) {
          // TODO
          if (verbose) {
            print('$pink<- C1 Application Program Comman ->');
          }
          continue;
        }
      }
      // PrintUtil.printd('cache.length -> ${cache.length}', 31);
      // TODO

      // print(' data[i]->${data[i]}');
      // PrintUtil.printd('posistion -> $currentPointer', 31);
      // PrintUtil.printd('cache -> $cache', 31);

      // print('$red getOrPerformLayout $i');
      final TextPainter painter = painterCache.getOrPerformLayout(
        TextSpan(
          text: data[i],
          style: TextStyle(
            // 误删，有用的，用来判断双宽度字符还是单宽度字符
            fontSize: theme.fontSize,
            height: 1,
          ),
        ),
      );
      // print('$red currentPointer->$currentPointer');
      // print('$red  painter width->${painter.width}');
      // print('$red  painter height->${painter.height}');
      // PrintUtil.printD('data[i]->${data[i]}');

      if (cache[currentPointer.y] == null) {
        cache[currentPointer.y] = SafeList<LetterEntity>();
      }
      cache[currentPointer.y][currentPointer.x] = LetterEntity(
        content: data[i],
        letterWidth: painter.width,
        letterHeight: painter.height,
        position: currentPointer,
        doubleWidth: painter.width == painter.height,
        fontColorTag: fontColorTag,
        backgroundColorTag: backgroundColorTag,
        fontStyleTag: fontStyleTag,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );
      if (painter.width == painter.height) {
        // 只有双字节字符宽高相等
        // 这儿应该有更好的方法
        moveToNextPosition();
      }

      moveToNextPosition();
    }
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
      case '40':
        return preTextStyle.copyWith(
          backgroundColor: theme.black,
        );
        break;
      case '41':
        return preTextStyle.copyWith(
          backgroundColor: theme.red,
        );
        break;
      case '42':
        return preTextStyle.copyWith(
          backgroundColor: theme.green,
        );
        break;
      case '43':
        return preTextStyle.copyWith(
          backgroundColor: theme.yellow,
        );
        break;
      case '44':
        return preTextStyle.copyWith(
          backgroundColor: theme.blue,
        );
        break;
      case '45':
        return preTextStyle.copyWith(
          backgroundColor: theme.purplishRed,
        );
        break;
      case '46':
        return preTextStyle.copyWith(
          backgroundColor: theme.cyan,
        );
        break;
      case '47':
        return preTextStyle.copyWith(
          backgroundColor: theme.white,
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
      case '00':
        return preTextStyle.copyWith(
          color: theme.defaultColor,
          backgroundColor: Colors.transparent,
        );
        break;
      default:
        return preTextStyle;
    }
  }
}
