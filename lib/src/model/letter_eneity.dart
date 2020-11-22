import 'package:flutter/material.dart';
import 'package:termare/src/painter/model/position.dart';

class LetterEntity {
  LetterEntity({
    @required this.content,
    @required this.letterWidth,
    @required this.letterHeight,
    @required this.position,
  });
  final String content;
  final double letterWidth;
  final double letterHeight;
  final Position position;
}
