import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/src/sequences/osc.dart';
import 'package:termare_view/termare_view.dart';

import 'core/safe_list.dart';
import 'core/letter_eneity.dart';
import 'core/text_attributes.dart';
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
    this.row = 25,
    this.column = 80,
    this.showBackgroundLine = false,
    this.fontFamily = 'packages/termare_view/DroidSansMono',
  }) {
    theme ??= TermareStyles.termux;
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    buffer = Buffer(this);
  }
  final String fontFamily;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

  void Function() onBell;
  void Function(TermSize size) sizeChanged;
  KeyboardInput keyboardInput;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  // String out = '';
  TermareStyle theme;
  // SafeList<SafeList<LetterEntity>> cache = SafeList();
  Buffer buffer;
  bool showCursor = true;
  // 当从 pty 读出内容的时候就会自动滑动
  bool autoScroll = true;
  // 显示背景网格
  bool showBackgroundLine;

  int row;
  int column;
  int topMargin = 0;
  int bottomMargin;
  TextAttributes textAttributes = TextAttributes('0');
  TextAttributes tmpTextAttributes;
  // void write(String data) => unixPthC.write(data);

  /// 直接指向 pty write 函数
  void write(String data) {
    dirty = true;

    parseOutput(data);
    notifyListeners();
  }

  // 光标的位置；
  Position currentPointer = Position(0, 0);
  // 用来适配ESC 7/8 这个序列，保存当前的光标位置
  Position tmpPointer = Position(0, 0);
  // 通过这个变量来滑动终端
  void clear() {
    buffer.clear();
    currentPointer = Position(0, 0);
    dirty = true;
  }

  void moveToPosition(int x) {
    // 玄学勿碰
    final int n = currentPointer.y * column + currentPointer.x;
    int target = n + x;
    if (target < 0) {
      target = 0;
    }
    currentPointer = Position(target % column, target ~/ column);
  }

  void setPtyWindowSize(Size size) {
    final int row = size.height ~/ theme.characterHeight;
    // 列数
    final int column = size.width ~/ theme.characterWidth;
    this.row = row;
    this.column = column;
    bottomMargin ??= row - 1;
    log('setPtyWindowSize $size row:$row column:$column');
    sizeChanged?.call(TermSize(row, column));
    dirty = true;
    notifyListeners();
  }

  void setFontSize(double fontSize) {
    // TODO 有错，不用怀疑，就是有错
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
    if (currentPointer.x + x >= column) {
      // 说明在行首
      return Position(
        currentPointer.x + x - column,
        currentPointer.y + 1,
      );
    } else if (currentPointer.x + x <= 0) {
      // 说明在行首
      return Position(
        column - 1,
        currentPointer.y - 1,
      );
    } else {
      return Position(currentPointer.x + x, currentPointer.y);
    }
  }

  void moveToOffset(int x, int y) {
    /// 减一的原因在于左上角为1;1
    currentPointer = Position(max(x - 1, 0), max(y - 1, 0));
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
    if (bottomMargin != row) {
      // int doNotNeedScrollLine = row - bottomMargin;
      // print('object ${currentPointer.y} $doNotNeedScrollLine');

      // cache[currentPointer.y + 1] = cache[currentPointer.y];
      // cache[currentPointer.y] = SafeList<LetterEntity>();
    }
    buffer.write(
      currentPointer.y,
      currentPointer.x,
      Character(
        content: char,
        letterWidth: painter.width,
        letterHeight: painter.height,
        position: currentPointer,
        doubleWidth: painter.width == painter.height,
        textAttributes: textAttributes,
      ),
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

  bool verbose = true;
  // 应该每次只接收一个字符
  void parseOutput(String data, {bool verbose = !kReleaseMode}) {
    // print('parseOutput ->$data<-');
    // log('$red utf8.encode(data)->${utf8.encode(data)}');
    for (int i = 0; i < data.length; i++) {
      // final List<int> codeUnits = data[i].codeUnits;
      // dart 的 codeUnits 是 utf32
      final List<int> utf8CodeUnits = utf8.encode(data[i]);
      // log('codeUnits->$codeUnits');
      // log('utf8CodeUnits->$utf8CodeUnits');
      if (utf8CodeUnits.length == 1) {
        // 说明单字节
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
    // buffer.write(
    //   currentPointer.y,
    //   currentPointer.x,
    //   Character(
    //     content: ' ',
    //     letterWidth: theme.characterWidth,
    //     letterHeight: theme.characterHeight,
    //     position: currentPointer,
    //     textAttributes: textAttributes,
    //   ),
    // );
  }
}
