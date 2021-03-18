import 'package:flutter/material.dart';
import 'package:termare_view/src/painter/model/position.dart';

import 'text_attributes.dart';

class Character {
  Character({
    this.textAttributes,
    this.wcwidth = 1,
    @required this.content,
  });
  final String content;
  // 这个不是dx或者px的字体宽度，是字符应该在终端中占有的宽度
  final int wcwidth;
  final TextAttributes textAttributes;
  bool get isEmpty => content == '';
  @override
  String toString() {
    return 'content:$content';
  }
}
