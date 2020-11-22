import 'dart:io';
import 'dart:ui';

import 'package:dart_pty/dart_pty.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare/src/painter/model/position.dart';

import 'package:collection/collection.dart';
import 'model/letter_eneity.dart';
import 'observable.dart';
import 'theme/term_theme.dart';
import 'painter/termare_painter.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
/// 在 Controller 被初始化的时候，底层终端已经被初始化了。

class TermareController with Observable {
  TermareController({
    this.theme = TermareStyles.termux,
    this.environment,
  }) {
    unixPthC = UnixPtyC(environment: environment);
    defaultStyle = TextStyle(
      textBaseline: TextBaseline.ideographic,
      height: 1,
      fontSize: theme.letterHeight - 2,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      // backgroundColor: Colors.black,
      // backgroundColor: Colors.red,
      fontFamily: 'monospace',
    );
    cache.length = rowLength;
    for (int i = 0; i < rowLength; i++) {
      cache[i] = [];
    }
    // print(cache);
    for (int i = 0; i < rowLength; i++) {
      cache[i].length = columnLength;
    }

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
  final Map<String, String> environment;

  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  // String out = '';
  final TermareStyle theme;
  UnixPtyC unixPthC;
  List<List<LetterEntity>> cache = [];
  bool showCursor = true;
  // 当从 pty 读出内容的时候就会自动滑动
  bool autoScroll = true;

  int rowLength = 57;
  int columnLength = 41;

  /// 直接指向 pty write 函数
  void write(String data) {
    parseOutput(data);
  }
  // void write(String data) => unixPthC.write(data);

  TextStyle defaultStyle;

  /// 指向 pty read 函数
  String read() => unixPthC.read();
  // 光标的位置
  Position currentPointer = Position(0, 0);
  String currentRead = '';
  Future<void> defineTermFunc(
    String func, {
    String tmpFilePath,
  }) async {
    tmpFilePath ??=
        '${PlatformUtil.getFilsePath(await PlatformUtil.getPackageName())}/tmp';
    print('定义函数中...--->$tmpFilePath');
    final File tmpFile = File(tmpFilePath);
    await tmpFile.writeAsString(func);
    print('创建临时脚本成功...->${tmpFile.path}');
    unixPthC.write(
      'export AUTO=TRUE\n',
    );
    unixPthC.write(
      'source $tmpFilePath\n',
    );
    unixPthC.write(
      'rm -rf $tmpFilePath\n',
    );
    while (true) {
      final bool exist = await tmpFile.exists();
      // 把不想被看到的代码读掉
      read();
      // print('read()->${read()}');
      if (!exist) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void moveToPosition(int x) {
    if (currentPointer.x + x >= columnLength) {
      // 说明在行首
      currentPointer = Position(
        currentPointer.x + x - columnLength,
        currentPointer.y + 1,
      );
    } else if (currentPointer.x + x <= 0) {
      // 说明在行首
      currentPointer = Position(
        columnLength - 1,
        currentPointer.y - 1,
      );
    } else {
      currentPointer = Position(currentPointer.x + x, currentPointer.y);
    }
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

  void parseOutput(String data) {
    // print('data->parseOutput->$data');
    for (int i = 0; i < data.length; i++) {
      final List<int> codeUnits = data[i].codeUnits;
      // print('codeUnits->${codeUnits}');
      final bool isDoubleByte = codeUnits.first > 0x7f;
      if (codeUnits.length == 1) {
        // 说明单字节
        if (eq(codeUnits, [0x07])) {
          PrintUtil.printn('<- C0 Bell ->', 31, 47);
          continue;
        }
        if (eq(codeUnits, [0x08])) {
          // 光标左移动
          PrintUtil.printn('<- C0 Backspace ->', 31, 47);
          Position prePosition = getToPosition(-1);
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
          cache[prePosition.y][prePosition.x] = null;
          continue;
        }

        if (eq(codeUnits, [0x09])) {
          moveToPosition(4);

          PrintUtil.printn('<- C0 Horizontal Tabulation ->', 31, 47);
          // print('<- Horizontal Tabulation ->');
          continue;
        }
        if (eq(codeUnits, [0x0a]) ||
            eq(codeUnits, [0x0b]) ||
            eq(codeUnits, [0x0c])) {
          moveToNextLinePosition();
          PrintUtil.printn('<- C0 Line Feed ->', 31, 47);
          continue;
        }
        if (eq(codeUnits, [0x0d])) {
          // ascii 13
          moveToLineFirstPosition();
          PrintUtil.printn('<- C0 Carriage Return ->', 31, 47);
          continue;
        }

        if (eq(codeUnits, [0x1b])) {
          // print('<- ESC ->');
          i += 1;
          final String curStr = data[i];
          PrintUtil.printd('preStr-> ESC curStr->$curStr', 31);
          switch (curStr) {
            case '[':
              i += 1;
              final String curStr = data[i];
              print(data.substring(i));
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
                  PrintUtil.printd('[ ? 后的值->${data.substring(i)}', 31);
                  continue;
                  break;
                default:
              }
              print('line.substring(i + 1)->${data.substring(i)}');
              final int charMindex = data.substring(i).indexOf('m');

              print('charMindex=======>$charMindex');
              String header = '';
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
        cache[currentPointer.y][currentPointer.x] = LetterEntity(
          content: data[i],
          letterWidth: painter.width,
          letterHeight: painter.height,
          position: currentPointer,
        );

        if (painter.width > theme.letterWidth) {
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
