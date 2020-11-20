import 'dart:io';

import 'package:dart_pty/dart_pty.dart';
import 'package:global_repository/global_repository.dart';

import 'observable.dart';
import 'theme/term_theme.dart';

/// Flutter Controller 的思想
/// 一个TermView对应一个 Controller
/// 在 Controller 被初始化的时候，底层终端已经被初始化了。

class TermareController with Observable {
  TermareController({
    this.theme = TermareStyles.termux,
    this.environment,
  }) {
    unixPthC = UnixPtyC(environment: environment);
  }
  final Map<String, String> environment;

  /// 通过这个值来判断终端是否需要刷新
  /// 每次从 pty 中读出数据的时候会将当前终端页标记为脏，在下一帧页终端就会进执行刷新
  bool dirty = false;
  String out = '';
  final TermareStyle theme;
  UnixPtyC unixPthC;

  bool showCursor = true;

  /// 直接指向 pty write 函数
  void write(String data) => unixPthC.write(data);

  /// 指向 pty read 函数
  String read() => unixPthC.read();

  Future<void> defineTermFunc(
    String func, {
    String tmpFilePath,
  }) async {
    tmpFilePath ??=
        '${PlatformUtil.getFilsePath(await PlatformUtil.getPackageName())}/tmp';
    print('定义函数中...--->$tmpFilePath');
    final File tmpFile = File(tmpFilePath);
    await tmpFile.writeAsString(func);
    print('创建临时脚本成功...->${tmpFile.path}');
    write(
      'export AUTO=TRUE\n',
    );
    write(
      'source $tmpFilePath\n',
    );
    write(
      'rm -rf $tmpFilePath\n',
    );
    while (true) {
      final bool exist = await tmpFile.exists();
      // 把不想被看到的代码读掉
      read();
      // print('read()->${read()}');
      if (!exist) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
