import 'package:flutter/material.dart';
import 'package:termare_view/src/painter/model/position.dart';

import 'text_attributes.dart';

class Character {
  Character({
    this.textAttributes,
    this.doubleWidth = false,
    @required this.content,
    @required this.letterWidth,
    @required this.letterHeight,
    @required this.position,
  });
  final String content;
  final double letterWidth;
  final double letterHeight;
  final Position position;
  final bool doubleWidth;
  final TextAttributes textAttributes;
  bool get isEmpty => content == '';
  @override
  String toString() {
    return '$content';
  }
}
