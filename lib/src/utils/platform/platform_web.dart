import 'dart:html' as html;

html.Navigator _navigator = html.window.navigator;

// ignore: avoid_classes_with_only_static_members
class GeneralPlatform {
  static bool get isWeb => true;

  static bool get isMacOS =>
      _navigator.appVersion.contains('Mac OS') && !GeneralPlatform.isIOS;

  static bool get isWindows => _navigator.appVersion.contains('Win');

  static bool get isLinux =>
      (_navigator.appVersion.contains('Linux') ||
          _navigator.appVersion.contains('x11')) &&
      !isAndroid;

  static bool get isAndroid => _navigator.appVersion.contains('Android ');

  static bool get isIOS {
    return false;
  }

  static bool get isFuchsia => false;

  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
