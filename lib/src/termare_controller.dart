import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/src/core/buffer.dart';
import 'package:termare_view/src/core/test.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/src/sequences/osc.dart';
import 'package:termare_view/termare_view.dart';

import 'core/safe_list.dart';
import 'core/character.dart';
import 'core/text_attributes.dart';
import 'core/observable.dart';
import 'input/key_handler.dart';
import 'painter/termare_painter.dart';
import 'sequences/c0.dart';
import 'sequences/c1.dart';
import 'sequences/csi.dart';
import 'sequences/esc.dart';
import 'theme/term_theme.dart';
import 'utils/character_width.dart';

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
    this.terminalTitle,
  }) {
    theme ??= TermareStyles.termux;
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    mainBuffer = Buffer(this);
    alternateBuffer = Buffer(this);
    currentBuffer = mainBuffer;
  }
  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! TermareController) {
      return false;
    }
    if (other is TermareController) {
      return other.hashCode == hashCode;
    }
    return false;
  }

  @override
  int get hashCode => mainBuffer.hashCode;
  final String fontFamily;
  bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

  void Function() onBell;
  void Function(TermSize size) sizeChanged;
  KeyboardInput input;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  // String out = '';
  TermareStyle theme;
  // SafeList<SafeList<LetterEntity>> cache = SafeList();
  Buffer currentBuffer;
  // 这个buffer在 CSI ? 1049 h 会用到
  Buffer alternateBuffer;
  Buffer mainBuffer;
  bool showCursor = true;
  // 当从 pty 读出内容的时候就会自动滑动
  bool autoScroll = true;
  // 显示背景网格
  bool showBackgroundLine;
  // 终端的标题，正在遇到 osc 序列的时候会改变
  String terminalTitle = '';
  int row;
  int column;
  TextAttributes textAttributes = TextAttributes('0');
  TextAttributes tmpTextAttributes;
  // void write(String data) => unixPthC.write(data);

  /// 直接指向 pty write 函数
  void write(String data) {
    dirty = true;

    processByte(data);
    notifyListeners();
  }

  // 光标的位置；
  Position currentPointer = Position(0, 0);
  // 用来适配ESC 7/8 这个序列，保存当前的光标位置
  Position tmpPointer = Position(0, 0);
  // 通过这个变量来滑动终端
  void clear() {
    currentBuffer.clear();
    currentPointer = Position(0, 0);
    dirty = true;
  }

  void switchBufferToAlternate() {
    currentBuffer = alternateBuffer;
    dirty = true;
    notifyListeners();
  }

  void switchBufferToMain() {
    currentBuffer = mainBuffer;
    dirty = true;
    notifyListeners();
  }

  void saveCursor() {
    tmpPointer = currentPointer;
  }

  void restoreCursor() {
    currentPointer = tmpPointer;
  }

  void setWindowSize(Size size) {
    final int row = size.height ~/ theme.characterHeight;
    // 列数
    final int column = size.width ~/ theme.characterWidth;
    this.row = row;
    this.column = column;
    log('setPtyWindowSize $size row:$row column:$column');
    currentBuffer.setViewPoint(row);
    sizeChanged?.call(TermSize(row, column - 1));
    dirty = true;
    execAutoScroll();
    notifyListeners();
  }

  void setFontSize(double fontSize) {
    // TODO 有错，不用怀疑，就是有错
    theme.fontSize = fontSize;
    final Size size = window.physicalSize;
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    setWindowSize(Size(screenWidth, screenHeight));
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

  void moveToPosition(int x) {
    // 玄学勿碰
    final int n = currentPointer.y * column + currentPointer.x;
    int target = n + x;
    if (target < 0) {
      target = 0;
    }
    currentPointer = Position(target % column, target ~/ column);
  }

  void moveToOffset(int x, int y) {
    /// 减一的原因在于左上角为1;1
    currentPointer = Position(
      max(x - 1, 0),
      max(
        y - 1 + currentBuffer.position,
        0,
      ),
    );
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
    // log('$red currentPointer->$currentPointer');
    // log('$red  painter width->${painter.width}');
    // log('$red  painter height->${painter.height}');
    // log('char->${char} ${cache.length}');

    final int characterWidth = CharacterWidth.width(char.codeUnits.first);
    final Character character = Character(
      content: char,
      wcwidth: characterWidth,
      textAttributes: textAttributes,
    );
    currentBuffer.write(
      currentPointer.y,
      currentPointer.x,
      character,
    );
    // TextPainter painter = painterCache.getOrPerformLayout(
    //   TextSpan(
    //     text: character.content,
    //     style: TextStyle(
    //       height: 1.0,
    //       fontSize: theme.fontSize,
    //       backgroundColor: Colors.transparent,
    //       color: character.textAttributes.foreground(this),
    //       fontWeight: FontWeight.w600,
    //       fontFamily: fontFamily,
    //       // fontStyle: FontStyle
    //     ),
    //   ),
    // );
    // print(
    //   'character.content -> ${character.content} painter.height -> ${painter.height}  painter.width -> ${painter.width}',
    // );
    moveToPosition(characterWidth);
  }

  void execAutoScroll() {
    // print('controller.currentPointer.y -> ${currentPointer.y}');
    // print('buffer.limit -> ${currentBuffer.limit}');
    if (currentPointer.y + 1 > currentBuffer.limit) {
      // print(
      //     '自动滑动 absLength:$absLength controller.rowLength:${controller.rowLength} controller.startLength:${controller.startLength}');
      // 上面这个if其实就是当终端视图下方还有显示内容的时候
      if (autoScroll) {
        // print('滚动 pointer ${currentPointer}');
        // 只能延时执行刷新
        // print(controller.currentPointer.y + 1 - buffer.limit);
        Future.delayed(const Duration(milliseconds: 10), () {
          currentBuffer.scroll(currentPointer.y + 1 - currentBuffer.limit);
          dirty = true;
          notifyListeners();
        });
        // lastLetterPositionCall(
        //   -controller.theme.letterHeight *
        //       (controller.cache.length - realColumnLen - controller.startLine),
        // );
      }
    } else {
      // if (controller.autoScroll) {
      //   // 只能延时执行刷新
      //   Future.delayed(const Duration(milliseconds: 10), () {
      //     controller.startLength =
      //         absLength - controller.startLength - controller.rowLength;
      //     controller.dirty = true;
      //     controller.notifyListeners();
      //   });
      //   // lastLetterPositionCall(
      //   //   -controller.theme.letterHeight *
      //   //       (controller.cache.length - realColumnLen - controller.startLine),
      //   // );
      // }
    }
    if (currentBuffer.absoluteLength() < currentBuffer.limit) {
      /// 这个触发会在键盘放下的时候，最后一行不在可视窗口底部的时候
      // print(
      //     '自动滑动 absLength:$absLength controller.rowLength:${controller.rowLength} controller.startLength:${controller.startLength}');
      // 上面这个if其实就是当终端视图下方还有显示内容的时候
      if (autoScroll) {
        // print('滚动 pointer ${currentPointer}');
        // 只能延时执行刷新
        // print(controller.currentPointer.y + 1 - buffer.limit);
        Future.delayed(const Duration(milliseconds: 10), () {
          currentBuffer.scroll(
            currentBuffer.absoluteLength() - currentBuffer.limit,
          );
          dirty = true;
          notifyListeners();
        });
        // lastLetterPositionCall(
        //   -controller.theme.letterHeight *
        //       (controller.cache.length - realColumnLen - controller.startLine),
        // );
      }
    }
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
  void processByte(String data, {bool verbose = !kReleaseMode}) {
    // print('-' * 10);
    // data.split(RegExp('\x0d')).forEach((element) {
    //   if (element.isNotEmpty) {
    //     print('>>>$element');
    //   }
    //   print('->${utf8.encode(element)}<-');
    // });
    // print('-' * 10);
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
            execAutoScroll();
            continue;
          }
        }
        if (csiStart) {
          Csi.handle(this, utf8CodeUnits);
          // execAutoScroll();
          continue;
        }
        if (escapeStart) {
          Esc.handle(this, utf8CodeUnits);
          execAutoScroll();
          continue;
        }
        final bool c0 = C0.handle(this, utf8CodeUnits);
        if (c0) {
          execAutoScroll();
          continue;
        }
      } else {
        // 双字节 0x84 在 utf8中一个字节是保存不下来的，按照utf8的编码规则，8位的第一位为1那么一定是两个字节
        // ，其中第一位需要拿来当符号位，但是dart是utf32，可以通过一个字节来解析
        final bool c1 = C1.handle(this, utf8CodeUnits);
        if (c1) {
          execAutoScroll();
          continue;
        }
      }
      writeChar(data[i]);
      execAutoScroll();
    }
  }
}
