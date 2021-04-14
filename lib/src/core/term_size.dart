import 'dart:ui';

import '../theme/term_theme.dart';

/// 一个对终端行数和列数的简单封装类
class TermSize {
  TermSize(this.row, this.column);
  final int row;
  final int column;
  static TermSize getTermSize(Size size) {
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.characterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.characterWidth;
    return TermSize(row, column);
  }
}
