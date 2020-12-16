import 'dart:ui';

import 'package:flutter/material.dart';

// class TermareStyle {
//   const TermareStyle(this.showCursor);
//   final bool showCursor;
// }
const Map<int, double> letterWidthMap = {
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

class TermareStyle {
  TermareStyle({
    this.fontSize = 12,
    this.cursorColor = Colors.grey,
    this.backgroundColor = Colors.black,
    this.defaultColor = Colors.white,
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
  TermareStyle copyWith({
    double fontSize = 12,
    Color cursorColor,
    Color backgroundColor,
    Color defaultColor,
    Color black,
    Color lightBlack,
    Color red,
    Color lightRed,
    Color green,
    Color lightGreen,
    Color yellow,
    Color lightYellow,
    Color blue,
    Color lightBlue,
    Color purplishRed,
    Color lightPurplishRed,
    Color cyan,
    Color lightCyan,
    Color white,
    Color lightWhite,
  }) {
    return TermareStyle(
      fontSize: fontSize ?? this.fontSize,
      cursorColor: cursorColor ?? this.cursorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      defaultColor: defaultColor ?? this.defaultColor,
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
  final Color defaultColor;
  // 前景色30 背景色40 黑色
  final Color black;
  final Color lightBlack;
  // 前景色31 背景色41 红色
  final Color red;
  final Color lightRed;
  // 前景色32 背景色42 绿色
  final Color green;
  final Color lightGreen;
  // 前景色33 背景色43 黄色
  final Color yellow;
  final Color lightYellow;
  // 前景色34 背景色44 蓝色
  final Color blue;
  final Color lightBlue;
  // 前景色35 背景色45 紫红色
  final Color purplishRed;
  final Color lightPurplishRed;
  // 前景色36 背景色46 青蓝色
  final Color cyan;
  final Color lightCyan;
  // 前景色37 背景色47 白色
  final Color white;
  final Color lightWhite;
  double get letterWidth => letterWidthMap[fontSize.toInt()];
  double get letterHeight => letterWidth * 2;
  double fontSize;
  @override
  String toString() {
    return '';
  }
}

class TermareStyles {
  TermareStyles._();
  static TermareStyle termux = TermareStyle(
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
  // static const  TermTheme manjaro;
  static TermareStyle macos = TermareStyle(
    defaultColor: Colors.black,
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
    defaultColor: Color(0xffaaaaaa),
    backgroundColor: Color(0xff454649),
    black: Color(0xff000000),
    lightBlack: Color(0xff000000),
    red: Color(0xffaa0000),
    lightRed: Color(0xffaa0000),
    green: Color(0xff00aa00),
    lightGreen: Color(0xff00aa00),
    yellow: Color(0xffaa5500),
    lightYellow: Color(0xffaa5500),
    blue: Color(0xff0000aa),
    lightBlue: Color(0xff0000aa),
    purplishRed: Color(0xffaa00aa),
    lightPurplishRed: Color(0xffaa00aa),
    cyan: Color(0xff00aaaa),
    lightCyan: Color(0xff00aaaa),
    white: Color(0xffaaaaaa),
    lightWhite: Color(0xffaaaaaa),
  );
}
