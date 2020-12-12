import 'dart:developer';
import 'dart:io';

// 针对平台
class PlatformUtil {
  static bool isMobilePhone() {
    return Platform.isAndroid || Platform.isIOS;
  }

  // 判断当前的设备是否是桌面设备
  static bool isDesktop() {
    return !isMobilePhone();
  }
}
