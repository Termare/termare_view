import 'dart:io';

import 'package:dart_pty/dart_pty.dart';
import 'package:global_repository/global_repository.dart';

import 'envirpath.dart';
import 'observable.dart';
import 'theme/term_theme.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
/// 在 Controller 被初始化的时候，底层终端已经被初始化了。
class TermareStyle {
  const TermareStyle();
  final bool showCursor = true;
}

class TermareController with Observable {
  final Map<String, String> environment;
  final TermareStyle termareStyle;
  TermareController(
      {this.termareStyle = const TermareStyle(), this.environment}) {
    unixPthC = UnixPtyC(environment: environment);
  }

  TermTheme theme = TermThemes.termux;
  UnixPtyC unixPthC;
  void write(String data) => unixPthC.write(data);
  String read() => unixPthC.read();
  StringBuffer buffer = StringBuffer();
  Future<void> defineTermFunc(String func, {String tmpFilePath}) async {
    tmpFilePath ??=
        '${PlatformUtil.getFilsePath(await PlatformUtil.getPackageName())}/1234567';
    print('定义函数中...--->$tmpFilePath');
    String cache = '';
    // OutCallback callback = (String output) {
    //   cache = output;
    //   print('output=====>$output');
    // };
    // addListener(callback);
    // print('创建临时脚本...');
    File tmpFile = File('$tmpFilePath');

    await tmpFile.writeAsString(func);
    // tmpFile.watch().listen((event) {
    //   print('event--->>>>>$event');
    // });
    print('创建临时脚本成功...->${tmpFile.path}');
    write(
      "export AUTO=TRUE\n",
    );
    write(
      "source $tmpFilePath\n",
    );
    write(
      "rm -rf $tmpFilePath\n",
    );
    while (true) {
      bool exist = await tmpFile.exists();
      read();
      // print('read()->${read()}');
      if (!exist) {
        break;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
