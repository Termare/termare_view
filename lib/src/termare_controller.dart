import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/src/sequences/osc.dart';
import 'package:termare_view/termare_view.dart';

import 'core/safe_list.dart';
import 'model/letter_eneity.dart';
import 'model/text_attributes.dart';
import 'core/observable.dart';
import 'painter/termare_painter.dart';
import 'sequences/c0.dart';
import 'sequences/c1.dart';
import 'sequences/csi.dart';
import 'sequences/esc.dart';
import 'theme/term_theme.dart';
import 'utils/keyboard_handler.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
String red = '\x1b[1;41;37m';
String pink = '\x1b[1;45;37m';
String green = '\x1B[1;42;31m';
String blue = '\x1b[1;46;37m';
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
  void Function(TermSize size) sizeChanged;
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
  int columnLength;

  TextAttributes textAttributes = TextAttributes('0');
  TextAttributes tmpTextAttributes;
  // void write(String data) => unixPthC.write(data);

  /// 直接指向 pty write 函数
  void write(String data) {
    dirty = true;

    parseOutput(data);
    notifyListeners();
  }

  int absoluteLength() {
    final int endRow = cache.length;
    // print('cache.length -> ${cache.length}');
    final int endColumn = columnLength;
    for (int row = endRow; row > 0; row--) {
      for (int column = 0; column < endColumn; column++) {
        if (cache[row] == null) {
          continue;
        }
        final LetterEntity letterEntity = cache[row][column];
        final bool isNotEmpty = letterEntity?.content?.isNotEmpty;
        if (isNotEmpty != null && isNotEmpty) {
          // print(
          //     'row + 1:${row + 1} currentPointer.y + 1 :${currentPointer.y + 1}');
          return max(row + 1, currentPointer.y + 1);
        }
      }
    }
    return currentPointer.y;
  }

  // 光标的位置；
  Position currentPointer = Position(0, 0);
  // 用来适配ESC 7/8 这个序列，保存当前的光标位置
  Position tmpPointer = Position(0, 0);
  // 通过这个变量来滑动终端
  int startLength = 0;
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
    log('setPtyWindowSize $size row:$rowLength column:$columnLength');
    sizeChanged?.call(TermSize(rowLength, columnLength));
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

  void moveToOffset(int x, int y) {
    /// 减一的原因在于左上角为1;1
    currentPointer = Position(max(x - 1, 0), max(y - 1 + startLength, 0));
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

  void moveToRelativeColumn(int ps) {
    currentPointer = Position(
      max(0, currentPointer.x + ps),
      currentPointer.y,
    );
  }

  void moveToAbsoluteColumn(int ps) {
    // 在竖直方向移动光标
    /// 因为 ps 为1的时候光标在第一行
    currentPointer = Position(
      ps - 1,
      currentPointer.y,
    );
  }

  void moveToAbsoluteRow(int ps) {
    // 在竖直方向移动光标
    /// 因为 ps 为1的时候光标在第一行
    currentPointer.moveTo(currentPointer.x, ps - 1);
  }

  void moveToRelativeRow(int ps) {
    currentPointer = Position(
      currentPointer.x,
      max(0, currentPointer.y + ps),
    );
  }

  void writeChar(String char) {
    final TextPainter painter = painterCache.getOrPerformLayout(
      TextSpan(
        text: char,
        style: TextStyle(
          // 误删，有用的，用来判断双宽度字符还是单宽度字符
          fontSize: theme.fontSize,
          fontFamily: fontFamily,
          height: 1,
        ),
      ),
    );
    // log('$red currentPointer->$currentPointer');
    // log('$red  painter width->${painter.width}');
    // log('$red  painter height->${painter.height}');
    // log('char->${char} ${cache.length}');

    if (cache[currentPointer.y] == null) {
      cache[currentPointer.y] = SafeList<LetterEntity>();
    }
    cache[currentPointer.y][currentPointer.x] = LetterEntity(
      content: char,
      letterWidth: painter.width,
      letterHeight: painter.height,
      position: currentPointer,
      doubleWidth: painter.width == painter.height,
      textAttributes: textAttributes,
    );
    if (painter.width == painter.height) {
      // 只有双字节字符宽高相等
      // 这儿应该有更好的方法
      moveToNextPosition();
    }

    moveToNextPosition();
  }

  // 不能放在 parseOutput 内部，可能存在一次流的末尾为终端序列的情况
  bool csiStart = false;
  bool oscStart = false;
  // 3f 是字符 ?
  bool csiAnd3fStart = false;
  bool escapeStart = false;
  bool dcsStart = false;
  // 是否按下 ctrl，可能监听到 ctrl 按键的时候改变这个值也可能在 app 端主动修改这个值
  bool ctrlEnable = false;
  void enbaleOrDisableCtrl() {
    ctrlEnable = !ctrlEnable;
    notifyListeners();
  }

  void log(Object object) {
    if (!kReleaseMode) {
      print(object);
    }
  }

  bool verbose = false;
  // 应该每次只接收一个字符
  void parseOutput(String data, {bool verbose = !kReleaseMode}) {
    print('parseOutput ->$data<-');
    log('$red utf8.encode(data)->${utf8.encode(data)}');
    for (int i = 0; i < data.length; i++) {
      if (i > data.length - 1) {
        break;
      }
      // final List<int> codeUnits = data[i].codeUnits;
      // dart 的 codeUnits 是 utf32
      final List<int> utf8CodeUnits = utf8.encode(data[i]);
      // log('codeUnits->$codeUnits');
      // log('utf8CodeUnits->$utf8CodeUnits');
      if (utf8CodeUnits.length == 1) {
        // 说明单字节
        if (csiAnd3fStart) {
          csiAnd3fStart = false;
          // 去拿那个字母的index
          final int charWordindex = data.substring(i).indexOf(RegExp('[a-z]'));
          log('line.substring($i)->${data.substring(i).split('\n').first}');
          String header = '';
          header = data.substring(i, i + charWordindex);
          final String sequenceChar = data.substring(i)[charWordindex];
          if (sequenceChar == 'l') {
            header.split(';').forEach((element) {
              log('ESC[?l序列 $element');
              if (element == '25') {
                showCursor = false;
              }
            });
          }
          if (sequenceChar == 'h') {
            header.split(';').forEach((element) {
              log('ESC[?h序列 $element');
              if (element == '25') {
                showCursor = true;
              }
            });
          }
          log('header->$header');

          i += header.length;
          continue;
        }
        if (oscStart) {
          final bool osc = Osc.handle(this, utf8CodeUnits);
          if (osc) {
            continue;
          }
        }
        if (csiStart) {
          Csi.handle(this, utf8CodeUnits);
          continue;
        }
        if (escapeStart) {
          Esc.handle(this, utf8CodeUnits);
          continue;
        }
        final bool c0 = C0.handle(this, utf8CodeUnits);
        if (c0) {
          continue;
        }
      } else {
        // 双字节 0x84 在 utf8中一个字节是保存不下来的，按照utf8的编码规则，8位的第一位为1那么一定是两个字节
        // ，其中第一位需要拿来当符号位，但是dart是utf32，可以通过一个字节来解析
        // TODO C1
        final bool c1 = C1.handle(this, utf8CodeUnits);
        if (c1) {
          continue;
        }
      }
      writeChar(data[i]);
      notifyListeners();
      // logUtil.logd('cache.length -> ${cache.length}', 31);
      // TODO

      // log(' data[i]->${data[i]}');
      // logUtil.logd('posistion -> $currentPointer', 31);
      // logUtil.logd('cache -> $cache', 31);

      // log('$red getOrPerformLayout $i');
      // TODO
    }
  }
}
