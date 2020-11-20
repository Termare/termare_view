import 'dart:ui';

import 'package:flutter/material.dart';

// class TermareStyle {
//   const TermareStyle(this.showCursor);
//   final bool showCursor;
// }
const double defaultLetterWidth = 9.0;
const double defaultLetterHeight = 14.0;

class TermareStyle {
  const TermareStyle({
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
    this.letterHeight = defaultLetterHeight,
    this.letterWidth = defaultLetterWidth,
  });
  TermareStyle copyWith({
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
  final double letterWidth;
  final double letterHeight;
}

class TermareStyles {
  static const TermareStyle termux = TermareStyle(
    cursorColor: Colors.grey,
    backgroundColor: Colors.black,
    black: Color(0xff000000),
    lightBlack: Color(0xff7f7f7f),
    red: Color(0xffcc0001),
    lightRed: Color(0xfffe0000),
    green: Color(0xff00cd00),
    lightGreen: Color(0xff00ff01),
    yellow: Color(0xffcecd00),
    lightYellow: Color(0xffffff00),
    blue: Color(0xff6395ec),
    lightBlue: Color(0xff5d5cff),
    purplishRed: Color(0xffce00cd),
    lightPurplishRed: Color(0xffff00fe),
    cyan: Color(0xff00cece),
    lightCyan: Color(0xff00ffff),
    white: Color(0xffe5e5e5),
    lightWhite: Color(0xffffffff),
  );
  // static const  TermTheme manjaro;
  static const TermareStyle macos = TermareStyle(
    defaultColor: Colors.black,
    backgroundColor: Color(0xffffffff),
    black: Color(0xff040404),
    lightBlack: Color(0xff030102),
    red: Color(0xffd50403),
    lightRed: Color(0xffd50304),
    green: Color(0xff05d329),
    lightGreen: Color(0xff08d424),
    yellow: Color(0xffb0c20c),
    lightYellow: Color(0xffabc017),
    blue: Color(0xff8109f1),
    lightBlue: Color(0xff8005ea),
    purplishRed: Color(0xfffd04e4),
    lightPurplishRed: Color(0xfff503dd),
    cyan: Color(0xff04c5d5),
    lightCyan: Color(0xff0cc5db),
    white: Color(0xffdccecd),
    lightWhite: Color(0xffd9d2d5),
  );
  static const TermareStyle manjaro = TermareStyle(
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
