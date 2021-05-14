import 'package:collection/collection.dart';
import 'package:termare_view/src/termare_controller.dart';

//
bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

/// 主要为了处理c0系列的终端序列
class C0 {
  static bool handle(TermareController controller, List<int> utf8CodeUnits) {
    final bool verbose = controller.verbose;
    if (eq(utf8CodeUnits, [0])) {
      if (controller.verbose) {
        // log('$red<- C0 NULL ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x07])) {
      controller.onBell?.call();
      // log('$red<- C0 Bell ->');
      return true;
    } else if (eq(utf8CodeUnits, [0x08])) {
      // 光标左移动
      if (verbose) {
        // log('$red<- C0 Backspace ->');
      }
      controller.moveToPrePosition();
      return true;
    } else if (eq(utf8CodeUnits, [0x09])) {
      controller.moveToPosition(4);
      if (verbose) {
        // log('$red<- C0 Horizontal Tabulation ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x0a]) ||
        eq(utf8CodeUnits, [0x0b]) ||
        eq(utf8CodeUnits, [0x0c])) {
      // TODO 有问题，应该是指向下移动光标才对
      controller.moveToNextLinePosition();
      controller.moveToLineFirstPosition();
      if (verbose) {
        // log('$red<- C0 Line Feed ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x0d])) {
      // ascii 13
      controller.moveToLineFirstPosition();
      if (verbose) {
        // log('$red<- C0 Carriage Return ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x0e])) {
      // TODO
      if (verbose) {
        // log('$red<- C0 Shift Out ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x0f])) {
      // TODO
      if (verbose) {
        // log('$red<- C0 Shift In ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0x1b])) {
      if (verbose) {
        // log('$red<- C0 Escape ->');
      }
      controller.escapeStart = true;
      return true;
    }
    return false;
  }
}
