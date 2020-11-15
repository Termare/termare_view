//这是终端控制序列的类
class TermControlSequences {
  // 当按下删除键时终端的输出序列
  static const List<int> deleteChar = <int>[8, 32, 8];
  // 重置终端的序列
  static const List<int> reset_term = <int>[
    27,
    99,
    27,
    40,
    66,
    27,
    91,
    109,
    27,
    91,
    74,
    27,
    91,
    63,
    50,
    53,
    104,
  ];
  // 发出蜂鸣的序列
  static const List<int> nullSeq = <int>[0x00];
  static const List<int> bell = <int>[0x07];
  static const List<int> backspace = <int>[0x08];
  static const List<int> horizontalTabulation = <int>[0x09];
  static const List<int> lineFeed = <int>[0x0a];
  static const List<int> verticalTabulation = <int>[0x0b];
  static const List<int> formFeed = <int>[0x0c];
  static const List<int> carriageReturn = <int>[0x0d];
  static const List<int> escapeR = <int>[13];
  static const List<int> escape = <int>[27];
}
