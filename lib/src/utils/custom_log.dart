library custom_log;

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class Log {
  static StringBuffer buffer = StringBuffer();
  static void v(Object object) {
    String data = '\x1B[1;40;37m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);
    print(data);
  }

  static void d(Object object) {
    String data = '\x1B[1;44;37m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);
    print(data);
  }

  static void i(Object object) {
    String data = '\x1B[1;44;37m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);
    print(data);
  }

  static void w(Object object) {
    String data = '\x1B[1;43;37m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);
    print(data);
  }

  static void e(Object object) {
    String data = '\x1B[1;41;37m $object \x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    buffer.write(data + suffix);
    print(data);
  }
}

void main() {
  Log.d('Debug log');
  Log.i('Info log');
  Log.w('Warning log');
  Log.e('Error log');
  Log.v('Verbose log');
}
