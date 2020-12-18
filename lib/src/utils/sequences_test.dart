import 'package:termare_view/src/termare_controller.dart';

class SequencesTest {
  static Future<void> testChinese(TermareController controller) async {
    controller.write('${'啊' * 17}\x08\x08 \n');
  }

  static Future<void> testColorText(TermareController controller) async {
    // 用来测试颜色序列
    controller.write(' \x1B[1;31m红色字\x1B[0m\n');
    controller.write(' \x1B[1;32m绿色字\x1B[0m\n');
    controller.write(' \x1B[1;33m黄色字\x1B[0m\n');
    controller.write(' \x1B[1;34m蓝色字\x1B[0m\n');
    controller.write(' \x1B[1;35m紫色字\x1B[0m\n');
    controller.write(' \x1B[1;36m天蓝字\x1B[0m\n');
    controller.write(' \x1B[1;37m白色字\x1B[0m\n');
    //
    controller.write(' \x1B[40;37m黑底白字\x1B[0m\n');
    controller.write(' \x1B[41;37m红底白字\x1B[0m\n');
    controller.write(' \x1B[42;37m绿底白字\x1B[0m\n');
    controller.write(' \x1B[43;37m黄底白字\x1B[0m\n');
    controller.write(' \x1B[44;37m蓝底白字\x1B[0m\n');
    controller.write(' \x1B[45;37m紫底白字\x1B[0m\n');
    controller.write(' \x1B[46;37m天蓝底白字\x1B[0m\n');
    controller.write(' \x1B[47;30m白底黑字\x1B[0m\n');
  }

  static Future<void> testMang(TermareController controller) async {
    final List<String> list = [
      '⣿',
      '⣷',
      '⣯',
      '⣟',
      '⡿',
      '⣿',
      '⢿',
      '⣻',
      '⣽',
      '⣾'
    ];
    for (final String str in list) {
      controller.write('$str\b');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  static Future<void> testIsOut(TermareController controller) async {
    // 测试终端自动滚动
    controller.write('\n');
    for (int i = 0; i < 5500; i++) {
      controller.write('${'${i % 10}' * 40}\n');
      controller.autoScroll = true;
      controller.dirty = true;
      controller.notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    controller.write('${'b' * 40}\n');
    controller.write('${'c' * 40}\n');
  }

  static void testC0(TermareController controller) {
    controller.write('bell test\x07\n');
    controller.write('Backspace Teaa\x08\x08st\n');
    controller.write('Horizontal\x09Tabulation\n');
    // 因为\x0a转换成string就是\n，所以不会被序列单独检测到
    controller.write('Line Feed\x0a\n');
    controller.write('Line Feed\x0b\n');
    controller.write('Line Feed\x0c\n');
    controller.write('${'a' * 47}\x0dbbb\n');
  }

  static void testDECSEL(TermareController controller) {
    controller.write('\n');
    controller.write('Backspace Teaa\x08\x1b[k\x08\x1b[kst\n');
  }

  static void testOSC(TermareController controller) {
    // controller.write('\x1b\x5d0;termare \x07set title to termare\n');
    controller.write('\x9d0;termare \x07set title to termare\n');
  }
}
