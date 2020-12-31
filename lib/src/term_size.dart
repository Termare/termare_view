import 'dart:ui';

import 'theme/term_theme.dart';

class TermSize {
  TermSize(this.row, this.column);
  final int row;
  final int column;
  static TermSize getTermSize(Size size) {
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.letterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.letterWidth;
    return TermSize(row, column);
  }
}
