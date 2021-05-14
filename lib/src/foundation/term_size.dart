import 'dart:ui';

import '../theme/term_theme.dart';

/// 一个对终端行数和列数的简单封装类
class TermSize {
  TermSize(this.row, this.column);
  // 这个功能的耦合太大，待后续优化
  TermSize.formSize(Size size) {
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    row = screenHeight ~/ TermareStyles.termux.characterHeight!;
    // 列数
    column = screenWidth ~/ TermareStyles.termux.characterWidth!;
  }

  late int row;
  late int column;

  @override
  String toString() {
    return 'row -> $row column -> $column';
  }
}
