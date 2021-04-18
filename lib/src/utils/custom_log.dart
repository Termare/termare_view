library custom_log;

import 'dart:developer';

class Log {
  static StringBuffer buffer = StringBuffer();
  static String tag = 'Termare View';
  static String prefix = '\x1b[38;5;244m[$tag] ';

  /// verbose
  static void v(Object object) {
    final String data = '\x1b[38;5;244m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);

    log(data, name: tag);
    // print(data);
  }

  static void d(Object object) {
    final String data = '\x1b[1;34m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);

    log(data, name: tag);
    // print(data);
  }

  static void i(Object object) {
    final String data = '\x1b[1;39m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);

    log(data, name: tag);
    // print(data);
  }

  static void w(Object object) {
    final String data = '\x1b[1;33m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);

    log(data, name: tag);
    // print(data);
  }

  static void e(Object object) {
    final String data = '\x1b[1;31m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);

    log(data, name: tag);
    // print(data);
  }
}

void main() {
  Log.d('Debug log');
  Log.i('Info log');
  Log.w('Warning log');
  Log.e('Error log');
  Log.v('Verbose log');
}
