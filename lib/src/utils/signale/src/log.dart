import 'core/logger.dart';

Logger defaultLogger = Logger();

class Log {
  static void d(Object object, {String? tag}) {
    defaultLogger.d(
      object,
      tag: tag,
    );
  }

  static void i(Object object, {String? tag}) {
    defaultLogger.i(
      object,
      tag: tag,
    );
  }

  static void w(Object object, {String? tag}) {
    defaultLogger.w(
      object,
      tag: tag,
    );
  }

  static void v(Object object, {String? tag}) {
    defaultLogger.v(
      object,
      tag: tag,
    );
  }

  static void e(Object object, {String? tag}) {
    defaultLogger.e(
      object,
      tag: tag,
    );
  }

  static void custom(
    Object object, {

    /// 前景色 0-255
    int? foreColor,

    /// 背景色 0-255
    int? backColor,
    String? tag,
  }) {
    defaultLogger.custom(
      object,
      foreColor: foreColor,
      backColor: backColor,
      tag: tag,
    );
  }
}

void main() {
  Log.d('Debug log');
  Log.i('Info log');
  Log.w('Warning log');
  Log.e('Error log');
  Log.v('Verbose log');
  Log.custom(
    'Custom log',
    foreColor: 10,
    backColor: 200,
  );
}
