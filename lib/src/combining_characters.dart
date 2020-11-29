class ShiftCombining {
  ShiftCombining._();
  static String getCombiningChar(String key) {
    print('key -> $key');
    if (shiftComChar.containsKey(key)) {
      return shiftComChar[key];
    }
    final RegExp regExp = RegExp('\\w');
    if (regExp.hasMatch(key)) {
      return key.toUpperCase();
    }
    return '';
  }

  static Map<String, String> shiftComChar = {
    '1': '!',
    '2': '@',
    '3': '#',
    '4': '\$',
    '5': '%',
    '6': '^',
    '7': '&',
    '8': '*',
    '9': '(',
    '0': ')',
    '`': '~',
  };
}
