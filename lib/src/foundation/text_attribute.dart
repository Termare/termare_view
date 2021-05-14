import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:termare_view/src/utils/signale/signale.dart';
import 'package:termare_view/termare_view.dart';

/// 用来描述终端每个节点的文本风格

class TextAttribute {
  TextAttribute(String textAttributes) {
    textAttributes = textAttributes;
    for (final String textAttribute in textAttributes.split(';')) {
      if (backgroundList.contains(textAttributes)) {
        _background = textAttribute;
      } else if (foregroundList.contains(textAttributes)) {
        _foreground = textAttribute;
      }
    }
    getForegroundColor = _getForegroundColor;
    getBackgroundColor = _getBackgroundColor;
  }

  TextAttribute.normal() {
    textAttributes = '0';
    getForegroundColor = _getForegroundColor;
    getBackgroundColor = _getBackgroundColor;
  }

  TextAttribute copyWith(String textAttributes, TermareController controller) {
    // print(
    //     '入参textAttributes -> $textAttributes 历史 textAttributes ->${this.textAttributes}');
    final TextAttribute tmpTextAttributes = TextAttribute.normal();
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
        Log.i('交换颜色');
        // swap = true;
        tmpTextAttributes.getForegroundColor =
            tmpTextAttributes._getBackgroundColor;
        tmpTextAttributes.getBackgroundColor =
            tmpTextAttributes._getForegroundColor;
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

  // 这玩意保存的是 `32;34` 这类的字符
  String? textAttributes;
  // defalut foreground color
  // 这个设置成 37 跟 40 切换主题会有问题
  String _foreground = '39';
  // defalut background color
  String _background = '49';
  // 前景扩展颜色由 `38` 开启
  bool _foregroundExtended = false;
  // 背景扩展颜色由 `48` 开启
  bool _backgroundExtended = false;
  // Color foregroundColor;
  // Color backgroundColor;
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
  // 这个 values 用来计算扩展颜色的 256 颜色
  static List<int> values = [
    0x00,
    0x5f,
    0x87,
    0xaf,
    0xd7,
    0xff,
  ];
  static Color? getExtendedColor(int tag, TermareController? controller) {
    assert(tag >= 0 && tag <= 256);
    final String tagChar = tag.toString();
    if (tag >= 0 && tag < 16) {
      switch (tagChar) {
        case '0':
          return controller!.theme!.black;
        case '8':
          return controller!.theme!.lightBlack;
        case '1':
          return controller!.theme!.red;
        case '9':
          return controller!.theme!.lightRed;
        case '2':
          return controller!.theme!.green;
        case '10':
          return controller!.theme!.lightGreen;
        case '3':
          return controller!.theme!.yellow;
        case '11':
          return controller!.theme!.lightYellow;
        case '4':
          return controller!.theme!.blue;
        case '12':
          return controller!.theme!.lightBlue;
        case '5':
          return controller!.theme!.purplishRed;
        case '13':
          return controller!.theme!.lightPurplishRed;
        case '6':
          return controller!.theme!.cyan;
        case '14':
          return controller!.theme!.lightCyan;
        case '7':
          return controller!.theme!.white;
        case '15':
          return controller!.theme!.lightWhite;
      }
    } else if (tag >= 16 && tag <= 231) {
      tag = tag - 16;
      final int red = tag % 6;
      final int green = (tag ~/ 6) % 6;
      final int blue = (tag ~/ 6) ~/ 6;
      // print('v---->$v  $v2');
      final Color color = Color.fromARGB(
        255,
        values[blue],
        values[green],
        values[red],
      );
      // print('color->$color');
      return color;
    } else if (tag > 231) {
      switch (tag) {
        case 232:
          return const Color(0xff080808);
        case 233:
          return const Color(0xff121212);
        case 234:
          return const Color(0xff1c1c1c);
        case 235:
          return const Color(0xff262626);
        case 236:
          return const Color(0xff303030);
        case 237:
          return const Color(0xff3a3a3a);
        case 238:
          return const Color(0xff444444);
        case 239:
          return const Color(0xff4e4e4e);
        case 240:
          return const Color(0xff585858);
        case 241:
          return const Color(0xff626262);
        case 242:
          return const Color(0xff6c6c6c);
        case 243:
          return const Color(0xff767676);
        case 244:
          return const Color(0xff808080);
        case 245:
          return const Color(0xff8a8a8a);
        case 246:
          return const Color(0xff949494);
        case 247:
          return const Color(0xff9e9e9e);
        case 248:
          return const Color(0xff9e9e9e);
        case 249:
          return const Color(0xffababab);
        case 250:
          return const Color(0xffb2b2b2);
        case 251:
          return const Color(0xffc6c6c6);
        case 252:
          return const Color(0xffd0d0d0);
        case 253:
          return const Color(0xffdadada);
        case 254:
          return const Color(0xffe4e4e4);
        case 255:
          return const Color(0xffececec);
        default:
      }
    }
    return null;
  }

  late Color? Function(TermareController? controller) getForegroundColor;
  late Color? Function(TermareController? controller) getBackgroundColor;

  Color? _getForegroundColor(TermareController? controller) {
    if (_foreground == null) {
      return controller!.theme!.defaultFontColor;
    }
    if (_foregroundExtended) {
      return getExtendedColor(int.tryParse(_foreground)!, controller);
    }
    switch (_foreground) {
      case '30':
        return controller!.theme!.black;
      case '90':
        return controller!.theme!.lightBlack;
      case '31':
        return controller!.theme!.red;
      case '91':
        return controller!.theme!.lightRed;
      case '32':
        return controller!.theme!.green;
      case '92':
        return controller!.theme!.lightGreen;
      case '33':
        return controller!.theme!.yellow;
      case '93':
        return controller!.theme!.lightYellow;
      case '34':
        return controller!.theme!.blue;
      case '94':
        return controller!.theme!.lightBlue;
      case '35':
        return controller!.theme!.purplishRed;
      case '95':
        return controller!.theme!.lightPurplishRed;
      case '36':
        return controller!.theme!.cyan;
      case '96':
        return controller!.theme!.lightCyan;
      case '37':
        return controller!.theme!.white;
      case '97':
        return controller!.theme!.lightWhite;
      case '39':
        return controller!.theme!.defaultFontColor;
      default:
        return controller!.theme!.defaultFontColor;
    }
  }

  Color? _getBackgroundColor(TermareController? controller) {
    if (_background == null) {
      return null;
    }
    if (_backgroundExtended) {
      return getExtendedColor(int.tryParse(_background)!, controller);
      // return
    }
    switch (_background) {
      case '8':
        return controller!.theme!.lightBlack;
      case '9':
        return controller!.theme!.lightRed;
      case '10':
        return controller!.theme!.lightGreen;
      case '11':
        return controller!.theme!.lightYellow;
      case '12':
        return controller!.theme!.lightBlue;
      case '13':
        return controller!.theme!.lightPurplishRed;
      case '14':
        return controller!.theme!.lightCyan;
      case '15':
        return controller!.theme!.lightWhite;
      case '40':
        return controller!.theme!.black;
      case '41':
        return controller!.theme!.red;
      case '42':
        return controller!.theme!.green;
      case '43':
        return controller!.theme!.yellow;
      case '44':
        return controller!.theme!.blue;
      case '45':
        return controller!.theme!.purplishRed;
      case '46':
        return controller!.theme!.cyan;
      case '47':
        return controller!.theme!.white;
      case '49':
        return controller!.theme!.backgroundColor;
      default:
        return controller!.theme!.black;
    }
  }
}
