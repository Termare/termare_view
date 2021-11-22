import 'dart:ui';

import 'package:flutter/material.dart';

// 在某一字体大小时，终端每一个格子的宽度
const Map<int, double> letterWidthMap = {
  4: 3.0,
  5: 4.0,
  6: 4.0,
  7: 5.0,
  8: 5.0,
  9: 6.0,
  10: 6.0,
  11: 7.0,
  12: 8.0,
  13: 8.0,
  14: 9.0,
  15: 9.0,
  16: 10.0,
  17: 11.0,
  18: 11.0,
  19: 12.0,
  20: 13.0,
  21: 13.0,
  22: 14.0,
  23: 14.0,
  24: 15.0,
};

// 在某一字体大小时，终端每一个格子的高度，通过上面的map的值乘2得到，保证终端为严格的宽:高为1:2
const Map<int, double> letterHeightMap = {
  4: 6.0,
  5: 8.0,
  6: 8.0,
  7: 10.0,
  8: 10.0,
  9: 12.0,
  10: 12.0,
  11: 14.0,
  12: 16.0,
  13: 16.0,
  14: 18.0,
  15: 18.0,
  16: 20.0,
  17: 22.0,
  18: 22.0,
  19: 24.0,
  20: 26.0,
  21: 26.0,
  22: 28.0,
  23: 28.0,
  24: 30.0,
};

// 用来表示终端风格的类
class TermareStyle {
  TermareStyle({
    this.fontSize = 12,
    this.cursorColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.defaultFontColor = Colors.white,
    this.black,
    this.lightBlack,
    this.red,
    this.lightRed,
    this.green,
    this.lightGreen,
    this.yellow,
    this.lightYellow,
    this.blue,
    this.lightBlue,
    this.purplishRed,
    this.lightPurplishRed,
    this.cyan,
    this.lightCyan,
    this.white,
    this.lightWhite,
  });

  factory TermareStyle.parse(String styleString) {
    switch (styleString) {
      case 'termux':
        return TermareStyles.termux;
      case 'manjaro':
        return TermareStyles.manjaro;
      case 'macos':
        return TermareStyles.macos;
      case 'vsCode':
        return TermareStyles.vsCode;
      default:
        return TermareStyles.vsCode;
    }
  }

  TermareStyle copyWith({
    double fontSize = 12,
    Color? cursorColor,
    Color? backgroundColor,
    Color? defaultFontColor,
    Color? black,
    Color? lightBlack,
    Color? red,
    Color? lightRed,
    Color? green,
    Color? lightGreen,
    Color? yellow,
    Color? lightYellow,
    Color? blue,
    Color? lightBlue,
    Color? purplishRed,
    Color? lightPurplishRed,
    Color? cyan,
    Color? lightCyan,
    Color? white,
    Color? lightWhite,
  }) {
    return TermareStyle(
      fontSize: fontSize,
      cursorColor: cursorColor ?? this.cursorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      defaultFontColor: defaultFontColor ?? this.defaultFontColor,
      black: black ?? this.black,
      lightBlack: lightBlack ?? this.lightBlack,
      red: red ?? this.red,
      lightRed: lightRed ?? this.lightRed,
      green: green ?? this.green,
      lightGreen: lightGreen ?? this.lightGreen,
      yellow: yellow ?? this.yellow,
      lightYellow: lightYellow ?? this.lightYellow,
      blue: blue ?? this.blue,
      lightBlue: lightBlue ?? this.lightBlue,
      purplishRed: purplishRed ?? this.purplishRed,
      lightPurplishRed: lightPurplishRed ?? this.lightPurplishRed,
      cyan: cyan ?? this.cyan,
      lightCyan: lightCyan ?? this.lightCyan,
      white: white ?? this.white,
      lightWhite: lightWhite ?? this.lightWhite,
    );
  }

  final Color cursorColor;
  final Color backgroundColor;
  final Color defaultFontColor;

  /// 前景色30 背景色40 黑色
  final Color? black;
  final Color? lightBlack;
  // 前景色31 背景色41 红色
  final Color? red;
  final Color? lightRed;
  // 前景色32 背景色42 绿色
  final Color? green;
  final Color? lightGreen;
  // 前景色33 背景色43 黄色
  final Color? yellow;
  final Color? lightYellow;
  // 前景色34 背景色44 蓝色
  final Color? blue;
  final Color? lightBlue;
  // 前景色35 背景色45 紫红色
  final Color? purplishRed;
  final Color? lightPurplishRed;
  // 前景色36 背景色46 青蓝色
  final Color? cyan;
  final Color? lightCyan;
  // 前景色37 背景色47 白色
  final Color? white;
  final Color? lightWhite;
  double? get characterWidth => letterWidthMap[fontSize.toInt()];
  double? get characterHeight => letterHeightMap[fontSize.toInt()];
  double fontSize;
  @override
  String toString() {
    return '';
  }
}

class TermareStyles {
  TermareStyles._();
  static TermareStyle termux = TermareStyle(
    fontSize: 11,
    defaultFontColor: Colors.white,
    cursorColor: Colors.grey,
    backgroundColor: Colors.black,
    black: const Color(0xff000000),
    lightBlack: const Color(0xff7f7f7f),
    red: const Color(0xffcc0001),
    lightRed: const Color(0xfffe0000),
    green: const Color(0xff00cd00),
    lightGreen: const Color(0xff00ff01),
    yellow: const Color(0xffcecd00),
    lightYellow: const Color(0xffffff00),
    blue: const Color(0xff6395ec),
    lightBlue: const Color(0xff5d5cff),
    purplishRed: const Color(0xffce00cd),
    lightPurplishRed: const Color(0xffff00fe),
    cyan: const Color(0xff00cece),
    lightCyan: const Color(0xff00ffff),
    white: const Color(0xffe5e5e5),
    lightWhite: const Color(0xffffffff),
  );

  static TermareStyle macos = TermareStyle(
    defaultFontColor: Colors.black,
    backgroundColor: const Color(0xffffffff),
    black: const Color(0xff000000),
    lightBlack: const Color(0xff666666),
    red: const Color(0xff990000),
    lightRed: const Color(0xffe50000),
    green: const Color(0xff00a600),
    lightGreen: const Color(0xff01d900),
    yellow: const Color(0xff999900),
    lightYellow: const Color(0xffe6e500),
    blue: const Color(0xff0000b3),
    lightBlue: const Color(0xff0000ff),
    purplishRed: const Color(0xffb200b3),
    lightPurplishRed: const Color(0xffe500e6),
    cyan: const Color(0xff00a6b3),
    lightCyan: const Color(0xff01e5e6),
    white: const Color(0xffbfbfbf),
    lightWhite: const Color(0xffe6e5e6),
  );
  static TermareStyle manjaro = TermareStyle(
    defaultFontColor: const Color(0xffaaaaaa),
    // backgroundColor: const Color(0xff454649),
    backgroundColor: const Color(0xff1b2224),
    black: const Color(0xff2e3436),
    lightBlack: const Color(0xff555753),
    red: const Color(0xffcc0000),
    lightRed: const Color(0xffef2929),
    green: const Color(0xff4e9a06),
    lightGreen: const Color(0xff8ae234),
    yellow: const Color(0xffc4a000),
    lightYellow: const Color(0xfffce94f),
    blue: const Color(0xff3465a4),
    lightBlue: const Color(0xff729fcf),
    purplishRed: const Color(0xff75507b),
    lightPurplishRed: const Color(0xffad7fa8),
    cyan: const Color(0xff06989a),
    lightCyan: const Color(0xff34e2e2),
    white: const Color(0xffd3d7cf),
    lightWhite: const Color(0xffeeeeec),
  );

  /// 从 vs code 中抓取的颜色
  static TermareStyle vsCode = TermareStyle(
    fontSize: 11,
    defaultFontColor: const Color(0xffffffff),
    backgroundColor: const Color(0xff1e1e1e),
    black: const Color(0xff000000),
    lightBlack: const Color(0xff666666),
    red: const Color(0xffcd3131),
    lightRed: const Color(0xfff14c4c),
    green: const Color(0xff0dbc79),
    lightGreen: const Color(0xff23d18b),
    yellow: const Color(0xffe5e510),
    lightYellow: const Color(0xfff5f543),
    blue: const Color(0xff2472c8),
    lightBlue: const Color(0xff3b8eea),
    purplishRed: const Color(0xffbc3fbc),
    lightPurplishRed: const Color(0xffd670d6),
    cyan: const Color(0xff11a8cd),
    lightCyan: const Color(0xff29b8db),
    white: const Color(0xffe5e5e5),
    lightWhite: const Color(0xffe5e5e5),
    cursorColor: const Color(0xffcccccc),
  );
}
