import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare/src/painter/model/position.dart';

import 'model/letter_eneity.dart';
import 'observable.dart';
import 'painter/termare_painter.dart';
import 'theme/term_theme.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
String red = '\x1b[31m';

String whiteBackground = '\x1b[47m';
String defaultColor = '\x1b[0m';

class TermareController with Observable {
  TermareController({
    this.theme,
    this.rowLength = 57,
    this.columnLength = 41,
  }) {
    theme ??= TermareStyles.termux;
    defaultStyle = TextStyle(
      textBaseline: TextBaseline.ideographic,
      height: 1,
      fontSize: theme.fontSize,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontFamily: 'packages/termare/DroidSansMono',
    );
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    // cache.length = cacheLine;
    // for (int i = 0; i < cacheLine; i++) {
    //   cache[i] = [];
    //   cache[i].length = columnLength;
    // }

    // print('\x1b[31m${stopwatch.elapsed}');
    // PrintUtil.printd('posistion -> $currentPointer', 31);
    // for (int i = 0; i < columnLength; i++) {
    //   moveToNextPosition();
    //   PrintUtil.printd('posistion -> $currentPointer', 31);
    // }
    // for (int i = 0; i < columnLength; i++) {
    //   moveToNextPosition();
    //   PrintUtil.printd('posistion -> $currentPointer', 31);
    // }
    // for (int i = 0; i < columnLength; i++) {
    //   moveToNextPosition();
    //   PrintUtil.printd('posistion -> $currentPointer', 31);
    // }
    // for (int i = 0; i < columnLength; i++) {
    //   moveToPrePosition();
    //   PrintUtil.printd('posistion -> $currentPointer', 31);
    // }
    // print(cache);
  }
  // final Map<String, String> environment;

  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;
  final int cacheLine = 1000;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  // String out = '';
  TermareStyle theme;
  List<List<LetterEntity>> cache = [];
  bool showCursor = true;
  // 当从 pty 读出内容的时候就会自动滑动
  bool autoScroll = true;
  // 显示背景网格
  bool showLine = false;

  int rowLength;
  int columnLength;

  // void write(String data) => unixPthC.write(data);

  TextStyle defaultStyle;

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

  void moveToPosition(int x) {
    if (currentPointer.x + x >= columnLength) {
      // 说明在行尾
      currentPointer = Position(
        currentPointer.x + x - columnLength,
        currentPointer.y + 1,
      );
    } else if (currentPointer.x + x <= 0) {
      // 说明在行首
      int yShould = currentPointer.y - 1;
      if (yShould < 0) {
        yShould = 0;
      }
      currentPointer = Position(
        columnLength - 1,
        yShould,
      );
    } else {
      currentPointer = Position(currentPointer.x + x, currentPointer.y);
    }
  }

  void setPtyWindowSize(Size size) {
    final int row = size.height ~/ theme.letterHeight;
    // 列数
    final int column = size.width ~/ theme.letterWidth;
    rowLength = row;
    columnLength = column;
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
    // PrintUtil.printd('moveToPrePosition', 35);
    moveToPosition(-1);
  }

  void moveToNextPosition() {
    // PrintUtil.printd('moveToNextPosition', 32);
    moveToPosition(1);
  }

  void moveToNextLinePosition() {
    currentPointer = Position(0, currentPointer.y + 1);
  }

  void moveToLineFirstPosition() {
    currentPointer = Position(0, currentPointer.y);
  }

  void verboseExec(void Function() call) {}
  void parseOutput(String data, {bool verbose = true}) {
    print('$red $whiteBackground parseOutput->$data');
    for (int i = 0; i < data.length; i++) {
      final List<int> codeUnits = data[i].codeUnits;
      // print('codeUnits->${codeUnits}');
      if (codeUnits.length == 1) {
        // 说明单字节
        if (eq(codeUnits, [0x07])) {
          PrintUtil.printn('<- C0 Bell ->', 31, 47);
          continue;
        }
        if (eq(codeUnits, [0x08])) {
          // 光标左移动
          // verboseExec(() {});
          if (verbose) {
            PrintUtil.printn('<- C0 Backspace ->', 31, 47);
          }
          final Position prePosition = getToPosition(-1);
          // PrintUtil.printn(
          //     'currentPointer -> $currentPointer prePosition -> $prePosition',
          //     31,
          //     47);
          // LetterEntity preEntity = cache[prePosition.y][prePosition.x];
          // if (preEntity == null) {
          //   prePosition = getToPosition(-2);
          //   preEntity = cache[prePosition.y][prePosition.x];
          // }
          // if (isDoubleByte) {
          //   // print('双字节字符---->${line[i]}');
          //   moveToPrePosition();
          // }
          moveToPrePosition();
          // cache[prePosition.y][prePosition.x] = null;
          continue;
        }

        if (eq(codeUnits, [0x09])) {
          moveToPosition(4);
          if (verbose) {
            PrintUtil.printn('<- C0 Horizontal Tabulation ->', 31, 47);
          }
          // print('<- Horizontal Tabulation ->');
          continue;
        }
        if (eq(codeUnits, [0x0a]) ||
            eq(codeUnits, [0x0b]) ||
            eq(codeUnits, [0x0c])) {
          moveToNextLinePosition();
          if (verbose) {
            PrintUtil.printn('<- C0 Line Feed ->', 31, 47);
          }
          continue;
        }
        if (eq(codeUnits, [0x0d])) {
          // ascii 13
          moveToLineFirstPosition();
          if (verbose) {
            PrintUtil.printn('<- C0 Carriage Return ->', 31, 47);
          }
          continue;
        }

        if (eq(codeUnits, [0x1b])) {
          // print('<- ESC ->');
          i += 1;
          final String curStr = data[i];
          if (verbose) {
            PrintUtil.printd('preStr-> ESC curStr->$curStr', 31);
          }
          switch (curStr) {
            case '[':
              i += 1;
              final String curStr = data[i];
              print(data.substring(i));
              if (verbose)
                PrintUtil.printd(
                  'preStr-> \x1b[32;7m[\x1b[31m ->curStr-> \x1b[32m$curStr\x1b[31m',
                  31,
                );
              switch (curStr) {
                // 27 91 75
                case 'K':
                  // i += 1;
                  // print(line[i - 5]);

                  // TODO 这个是删除的序列，写得有问题
                  // bool isDoubleByte = doubleByteReg.hasMatch(line[i - 5]);
                  // if (isDoubleByte) {
                  //   // print('数按字节字符---->${line[i]}');
                  // }
                  // canvas.drawRect(
                  //   Rect.fromLTWH(
                  //     _position.dx * theme.letterWidth,
                  //     _position.dy * theme.letterHeight +
                  //         defaultOffsetY,
                  //     false
                  //         ? 2 * theme.letterWidth
                  //         : theme.letterWidth,
                  //     theme.letterHeight,
                  //   ),
                  //   Paint()..color = Colors.black,
                  // );
                  continue;
                  break;
                case '?':
                  i += 1;
                  final RegExp regExp = RegExp('l');
                  final int w = data.substring(i + 1).indexOf(regExp);
                  final String number = data.substring(i, i + w);
                  if (number == '25') {
                    i += 2;
                    showCursor = false;
                  }
                  i += 1;
                  if (verbose)
                    PrintUtil.printd('[ ? 后的值->${data.substring(i)}', 31);
                  continue;
                  break;
                default:
              }
              print('line.substring(i + 1)->${data.substring(i)}');
              final int charMindex = data.substring(i).indexOf('m');

              print('charMindex=======>$charMindex');
              String header = '';
              // TODO  有错
              header = data.substring(i, i + charMindex);
              print('header->$header');
              header.split(';').forEach((element) {
                defaultStyle = getTextStyle(element, defaultStyle);
              });
              i += header.length;
              break;
            default:
          }
          continue;
        }
        // PrintUtil.printd('cache.length -> ${cache.length}', 31);
        // TODO
        if (cache.length < currentPointer.y + 1) {
          // 会越界
          cache.length = currentPointer.y + 1;
          cache[currentPointer.y] = [];
          cache[currentPointer.y].length = columnLength;
        }
        // print(' data[i]->${data[i]}');
        // PrintUtil.printd('posistion -> $currentPointer', 31);
        // PrintUtil.printd('cache -> $cache', 31);
        final TextPainter painter = painterCache.getOrPerformLayout(
          TextSpan(
            text: data[i],
            style: defaultStyle,
          ),
        );
        // PrintUtil.printD('currentPointer->$currentPointer');
        // PrintUtil.printD('data[i]->${data[i]}');

        cache[currentPointer.y][currentPointer.x] = LetterEntity(
          content: data[i],
          letterWidth: painter.width,
          letterHeight: painter.height,
          position: currentPointer,
          textStyle: defaultStyle.copyWith(fontSize: theme.fontSize),
        );

        if (painter.width == painter.height) {
          // 只有双字节字符宽高相等
          // 这儿应该有更好的方法
          moveToNextPosition();
        }

        moveToNextPosition();

        /// ------------------ c0 ----------------------
      }
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
      case '42':
        return preTextStyle.copyWith(
          backgroundColor: theme.green,
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
      default:
        return preTextStyle;
    }
  }
}
