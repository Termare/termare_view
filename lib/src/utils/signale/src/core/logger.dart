String _ansiCsi = '\x1b[';
String _defaultColor = '${_ansiCsi}0m';
String _verboseSeq = '${_ansiCsi}38;5;244m';

class Logger {
  final StringBuffer _buffer = StringBuffer();

  StringBuffer get buffer => _buffer;

  String tag = '';

  /// verbose
  void v(Object object, {String? tag}) {
    final String data = '$_verboseSeq$object$_defaultColor';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    _buffer.write(data + suffix);
    _printCall(data, tag ?? 'V');
  }

  void d(Object object, {String? tag}) {
    final String data = '${_ansiCsi}1;34m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    _buffer.write(data + suffix);
    _printCall(data, tag ?? 'D');
  }

  void i(Object object, {String? tag}) {
    final String data = '${_ansiCsi}1;39m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    _buffer.write(data + suffix);
    _printCall(data, tag ?? 'I');
  }

  void w(Object object, {String? tag}) {
    final String data = '${_ansiCsi}1;33m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    _buffer.write(data + suffix);
    _printCall(data, tag ?? 'W');
  }

  void e(Object object, {String? tag}) {
    final String data = '${_ansiCsi}1;31m$object\x1B[0m';
    String suffix = '';
    if (!object.toString().endsWith('\n')) {
      suffix += '\n';
    }
    _buffer.write(data + suffix);
    _printCall(data, tag ?? 'E');
  }

  void _printCall(String data, String tag) {
    print('$_verboseSeq[$tag] $data');
  }

  void custom(
    Object object, {
    int? foreColor,
    int? backColor,
    String? tag,
  }) {
    String foreTag = '38';
    String backTag = '48';
    if (foreColor == null) {
      foreTag = '39';
    }
    if (backColor == null) {
      backTag = '49';
    }
    _printCall(
      '$_ansiCsi$foreTag;5;${foreColor ?? '0'}m$_ansiCsi$backTag;5;${backColor ?? '0'}m$object$_defaultColor',
      tag ?? 'Custom',
    );
  }
}
