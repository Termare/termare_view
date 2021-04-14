import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:termare_view/termare_view.dart';

/// 用来保存终端每个节点的文本风格

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
    // print(
    //     '入参textAttributes -> $textAttributes 历史 textAttributes ->${this.textAttributes}');
    final TextAttributes tmpTextAttributes = TextAttributes.normal();
    if (textAttributes == '0' || textAttributes == '00') {
      return tmpTextAttributes;
    }
    tmpTextAttributes._background = _background;
    tmpTextAttributes._foreground = _foreground;
    for (final String textAttribute in textAttributes.split(';')) {
      // print('textAttribute -> $textAttribute');
      if (tmpTextAttributes._foregroundExtended) {
        // 前景色扩展开启，到来的attr为前景色
        tmpTextAttributes._foreground = textAttribute;
      } else if (tmpTextAttributes._backgroundExtended) {
        tmpTextAttributes._background = textAttribute;
      } else if (backgroundList.contains(textAttribute)) {
        tmpTextAttributes._background = textAttribute;
      } else if (foregroundList.contains(textAttribute)) {
        tmpTextAttributes._foreground = textAttribute;
      } else if (textAttribute == '38') {
        // print('开启前景色扩展');
        tmpTextAttributes._foregroundExtended = true;
      } else if (textAttribute == '48') {
        // print('开启背景色扩展');
        tmpTextAttributes._backgroundExtended = true;
      } else if (textAttribute == '7') {
        // flips = true;
        print('交换颜色');
        final String swap = tmpTextAttributes._background;
        tmpTextAttributes._background =
            _foreground.replaceAll(RegExp('^3'), '4');
        tmpTextAttributes._foreground = swap.replaceAll(RegExp('^4'), '3');
      }
    }
    // print(
    //     '入参textAttributes -> $textAttributes 历史 textAttributes ->${this.textAttributes}');
    // if (textAttributes == '0') {
    //   textAttributes = '0';
    // } else if (!this.textAttributes.split(';').contains(textAttributes)) {
    //   this.textAttributes += ';$textAttributes';
    // }
    // print('tmpTextAttributes -> $tmpTextAttributes');
    return tmpTextAttributes;
    // return TextAttributes(this.textAttributes);
  }

  @override
  String toString() {
    return 'background : $_background foreground : $_foreground foregroundExtended:$_foregroundExtended _backgroundExtended:$_backgroundExtended';
  }

  String textAttributes;
  String _foreground = '39';
  String _background = '49';
  bool _foregroundExtended = false;
  bool _backgroundExtended = false;
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
    '49',
  ];
  final List<String> foregroundList = [
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '39',
    '90',
    '91',
    '92',
    '93',
    '94',
    '95',
    '96',
    '97',
  ];
  static List<int> values = [
    0x00,
    0x5f,
    0x87,
    0xaf,
    0xd7,
    0xff,
  ];
  static Color getExtendedColor(int tag, TermareController controller) {
    assert(tag >= 0 && tag <= 256);
    // print('_background ->$tag');
    //00 5f 87 af d7 ff
    final String tagChar = tag.toString();
    if (tag >= 0 && tag < 16) {
      switch (tagChar) {
        case '0':
          return controller.theme.black;
          break;
        case '8':
          return controller.theme.lightBlack;
          break;
        case '1':
          return controller.theme.red;
          break;
        case '9':
          return controller.theme.lightRed;
          break;
        case '2':
          return controller.theme.green;
          break;
        case '10':
          return controller.theme.lightGreen;
          break;
        case '3':
          return controller.theme.yellow;
          break;
        case '11':
          return controller.theme.lightYellow;
          break;
        case '4':
          return controller.theme.blue;
          break;
        case '12':
          return controller.theme.lightBlue;
          break;
        case '5':
          return controller.theme.purplishRed;
          break;
        case '13':
          return controller.theme.lightPurplishRed;
          break;
        case '6':
          return controller.theme.cyan;
          break;
        case '14':
          return controller.theme.lightCyan;
          break;
        case '7':
          return controller.theme.white;
          break;
        case '15':
          return controller.theme.lightWhite;
          break;
      }
    } else if (tag >= 16 && tag <= 231) {
      tag = tag - 16;
      int v = tag % 6;
      int v2 = (tag ~/ 6) % 6;
      int v3 = (tag ~/ 6) ~/ 6;
      // print('v---->$v  $v2');
      final Color color =
          Color.fromARGB(255, values[v3], values[v2], values[v]);
      // print('color->$color');
      return color;
    } else if (tag > 231) {
      switch (tag) {
        case 232:
          return const Color(0xff080808);
          break;
        case 233:
          return const Color(0xff080808);
          break;
        case 234:
          return const Color(0xff080808);
          break;
        case 235:
          return const Color(0xff080808);
          break;
        case 236:
          return const Color(0xff080808);
          break;
        case 237:
          return const Color(0xff080808);
          break;
        case 238:
          return const Color(0xff080808);
          break;
        case 239:
          return const Color(0xff080808);
          break;
        case 240:
          return const Color(0xff080808);
          break;
        //todo
        default:
      }
    }
    return null;
  }

  Color foreground(TermareController controller) {
    if (_foreground == null) {
      return controller.theme.defaultColor;
    }
    if (_foregroundExtended) {
      return getExtendedColor(int.tryParse(_foreground), controller);
      // return
    }
    switch (_foreground) {
      case '30':
        return controller.theme.black;
        break;
      case '90':
        return controller.theme.lightBlack;
        break;
      case '31':
        return controller.theme.red;
        break;
      case '91':
        return controller.theme.lightRed;
        break;
      case '32':
        return controller.theme.green;
        break;
      case '92':
        return controller.theme.lightGreen;
        break;
      case '33':
        return controller.theme.yellow;
        break;
      case '93':
        return controller.theme.lightYellow;
        break;
      case '34':
        return controller.theme.blue;
        break;
      case '94':
        return controller.theme.lightBlue;
        break;
      case '35':
        return controller.theme.purplishRed;
        break;
      case '95':
        return controller.theme.lightPurplishRed;
        break;
      case '36':
        return controller.theme.cyan;
        break;
      case '96':
        return controller.theme.lightCyan;
        break;
      case '37':
        return controller.theme.white;
        break;
      case '97':
        return controller.theme.lightWhite;
        break;
      case '39':
        return controller.theme.defaultColor;
        break;
      default:
        return controller.theme.defaultColor;
    }
  }

  Color background(TermareController controller) {
    if (_background == null) {
      return null;
    }
    if (_backgroundExtended) {
      return getExtendedColor(int.tryParse(_background), controller);
      // return
    }
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
      case '40':
        return controller.theme.black;
        break;
      case '41':
        return controller.theme.red;
        break;
      case '42':
        return controller.theme.green;
        break;
      case '43':
        return controller.theme.yellow;
        break;
      case '44':
        return controller.theme.blue;
        break;
      case '45':
        return controller.theme.purplishRed;
        break;
      case '46':
        return controller.theme.cyan;
        break;
      case '47':
        return controller.theme.white;
        break;
      case '49':
        return controller.theme.backgroundColor;
        break;
      default:
        return controller.theme.black;
    }
  }
}
