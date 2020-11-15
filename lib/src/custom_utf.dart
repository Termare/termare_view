import 'dart:convert';
import 'dart:ffi';

class NiUtf {
  List<int> unitsCache = <int>[]; //这个缓存是为了解决拿到的最后字符不完整
  String listToStaring(List<int> units) {
    int len = units.length;
    units = unitsCache + units;
    // print('len=====$len');
    len = len + unitsCache.length;
    print('>>>>>>>>>len======$len');
    unitsCache.clear();
    //只有当为0开头经过二进制转换才小于7位，如果读取到的最后一个字符为0开头，
    //说明这整个UTF8字符占用1个字节，不存在后面还有其他字节没有读取到的情况
    /// 128
    /// 10000000
    if (units.last & 0xff & 128 == 0) {
      // print('===>${units.last}');
      try {
        return utf8.decode(units, allowMalformed: false);
      } catch (e) {
        print(units);
        print(e);
      }

      ///  11000000
      /// &11111111
      /// =11000000
    } else if (units.last & 192 == 192) {
      print('结尾数');
      unitsCache = units.sublist(len - 1, len);
      units.removeRange(len - 1, len);
    } else {
      // print('发现需要拼包的序列');
      // print(units.last);
      // print(units);
      // print('拆包中');
      int number = 0;
      while (true) {
        //等于2说明移位后为10
        final int cur = units[len - 1 - number];
        // print('当前指向的数===>$cur');
        if (cur >> 6 == 2) {
          // print('经过一个10');
          //经过一次10开头的便记录一次
        } else if (cur.toRadixString(2).startsWith('1' * (number + 2))) {
          //此时该字节以number+2个字节开始，说明该次读取不完整
          //因为此时该字节开始的1应该为number+1个(10开始的个数加上此时这个字节)
          unitsCache = units.sublist(len - number, len);
          units.removeRange(len - number, len);
          break;
        } else if (cur.toRadixString(2).startsWith('1' * (number + 1))) {
          {
            break;
          }
        }
        number++;
      }
    }
    try {
      return utf8.decode(units, allowMalformed: true);
    } catch (e) {
      print('===>$units');
      print(e);
    }
    return null;
  }

  String cStringtoString(Pointer<Uint8> str) {
    if (str == null) {
      return null;
    }
    int len = 0;
    while (str.elementAt(++len).value != 0) {}
    List<int> units = List<int>(len);
    for (int i = 0; i < len; ++i) {
      units[i] = str.elementAt(i).value;
    }
    units = unitsCache + units;
    // print('len=====$len');
    len = len + unitsCache.length;
    unitsCache.clear();
    //只有当为0开头经过二进制转换才小于7位，如果读取到的最后一个字符为0开头，
    //说明这整个UTF8字符占用1个字节，不存在后面还有其他字节没有读取到的情况
    /// 128
    /// 10000000
    if (units.last & 128 == 0) {
      // print('===>${units.last}');
      try {
        return utf8.decode(units, allowMalformed: false);
      } catch (e) {
        print(units);
        print(e);
      }

      ///  11000000
      /// &11111111
      /// =11000000
    } else if (units.last & 192 == 192) {
      print('结尾数');
      unitsCache = units.sublist(len - 1, len);
      units.removeRange(len - 1, len);
    } else {
      // print('发现需要拼包的序列');
      // print(units.last);
      // print(units);
      // print('拆包中');
      int number = 0;
      while (true) {
        //等于2说明移位后为10
        final int cur = units[len - 1 - number];
        // print('当前指向的数===>$cur');
        if (cur >> 6 == 2) {
          // print('经过一个10');
          //经过一次10开头的便记录一次
        } else if (cur.toRadixString(2).startsWith('1' * (number + 2))) {
          //此时该字节以number+2个字节开始，说明该次读取不完整
          //因为此时该字节开始的1应该为number+1个(10开始的个数加上此时这个字节)
          unitsCache = units.sublist(len - number, len);
          units.removeRange(len - number, len);
          break;
        } else if (cur.toRadixString(2).startsWith('1' * (number + 1))) {
          {
            break;
          }
        }
        number++;
      }
    }
    try {
      return utf8.decode(units, allowMalformed: false);
    } catch (e) {
      print('===>$units');
      print(e);
    }
    return null;
  }
}
