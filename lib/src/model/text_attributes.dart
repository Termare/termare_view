import 'dart:ui';

import 'package:termare_view/termare_view.dart';

class TextAttributes {
  TextAttributes(String textAttributes) {
    textAttributes = textAttributes;
    for (final String textAttribute in textAttributes.split(';')) {
      if (backgroundList.contains(textAttributes)) {
        _background = textAttribute;
      } else if (foregroundList.contains(textAttributes)) {
        _foreground = textAttribute;
      }
    }
  }
  TextAttributes.normal() {
    textAttributes = '0';
  }
  TextAttributes copyWith(String textAttributes) {
    print(
        '入参textAttributes -> $textAttributes 历史 textAttributes ->${this.textAttributes}');
    final TextAttributes tmpTextAttributes = TextAttributes.normal();
    if (textAttributes == '0' || textAttributes == '00') {
      return tmpTextAttributes;
    }
    tmpTextAttributes._background = _background;
    tmpTextAttributes._foreground = _foreground;
    for (final String textAttribute in textAttributes.split(';')) {
      // print('textAttribute -> $textAttribute');
      if (backgroundList.contains(textAttribute)) {
        tmpTextAttributes._background = textAttribute;
      } else if (foregroundList.contains(textAttribute)) {
        tmpTextAttributes._foreground = textAttribute;
      }
    }
    // print(
    //     '入参textAttributes -> $textAttributes 历史 textAttributes ->${this.textAttributes}');
    // if (textAttributes == '0') {
    //   textAttributes = '0';
    // } else if (!this.textAttributes.split(';').contains(textAttributes)) {
    //   this.textAttributes += ';$textAttributes';
    // }
    print('tmpTextAttributes -> $tmpTextAttributes');
    return tmpTextAttributes;
    // return TextAttributes(this.textAttributes);
  }

  @override
  String toString() {
    return 'background : $_background foreground : $_foreground';
  }

  String textAttributes;
  String _foreground;
  String _background;
  final List<String> backgroundList = [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
  ];
  final List<String> foregroundList = [
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37'
  ];
  Color foreground(TermareController controller) {
    if (_foreground == null) {
      return controller.theme.defaultColor;
    }
    switch (_foreground) {
      case '30':
        return controller.theme.black;

        return controller.theme.lightBlack;
        break;
      case '31':
        return controller.theme.red;

        return controller.theme.lightRed;
        break;
      case '32':
        return controller.theme.green;

        return controller.theme.lightGreen;
        break;
      case '33':
        return controller.theme.yellow;

        return controller.theme.lightYellow;
        break;
      case '34':
        return controller.theme.blue;

        return controller.theme.lightBlue;
        break;
      case '35':
        return controller.theme.purplishRed;

        return controller.theme.lightPurplishRed;
        break;
      case '36':
        return controller.theme.cyan;

        return controller.theme.lightCyan;
        break;
      case '37':
        return controller.theme.white;

        return controller.theme.lightWhite;
        break;
      default:
        return controller.theme.defaultColor;
    }
  }

  Color background(TermareController controller) {
    if (_background == null) {
      return null;
    }
    // TODO 垃圾代码
    switch (_background) {
      case '8':
        return controller.theme.lightBlack;
        break;
      case '9':
        return controller.theme.lightRed;
        break;
      case '10':
        return controller.theme.lightGreen;
        break;
      case '11':
        return controller.theme.lightYellow;
        break;
      case '12':
        return controller.theme.lightBlue;
        break;
      case '13':
        return controller.theme.lightPurplishRed;
        break;
      case '14':
        return controller.theme.lightCyan;
        break;
      case '15':
        return controller.theme.lightWhite;
        break;
    }
    switch (_background) {
      case '40':
        return controller.theme.black;

        return controller.theme.lightBlack;
        break;
      case '41':
        return controller.theme.red;

        return controller.theme.lightRed;
        break;
      case '42':
        return controller.theme.green;

        return controller.theme.lightGreen;
        break;
      case '43':
        return controller.theme.yellow;

        return controller.theme.lightYellow;
        break;
      case '44':
        return controller.theme.blue;

        return controller.theme.lightBlue;
        break;
      case '45':
        return controller.theme.purplishRed;

        return controller.theme.lightPurplishRed;
        break;
      case '46':
        return controller.theme.cyan;

        return controller.theme.lightCyan;
        break;
      case '47':
        return controller.theme.white;

        return controller.theme.lightWhite;
        break;
      default:
        return controller.theme.black;
    }
  }
}
