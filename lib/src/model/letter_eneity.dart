import 'package:flutter/material.dart';
import 'package:termare_view/src/painter/model/position.dart';

class LetterEntity {
  LetterEntity({
    this.foregroundColor,
    this.backgroundColor,
    this.fontColorTag,
    this.backgroundColorTag,
    this.fontStyleTag,
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
  final String fontColorTag;
  final String backgroundColorTag;
  final String fontStyleTag;
  //TODO
  final String backgroundColor;
  final String foregroundColor;
}
