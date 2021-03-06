import 'package:collection/collection.dart';
import 'package:termare_view/termare_view.dart';

bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

class C1 {
  static bool handle(TermareController controller, List<int> utf8CodeUnits) {
    if (eq(utf8CodeUnits, [0xc2, 0x84])) {
      // c1 序列
      controller.moveToNextLinePosition();
      if (controller.verbose) {
        controller.log('$pink<- C1 Index ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x85])) {
      controller.moveToNextLinePosition();
      controller.moveToLineFirstPosition();
      if (controller.verbose) {
        controller.log('$pink<- C1 Next Line ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x88])) {
      controller.moveToPosition(4);
      if (controller.verbose) {
        controller.log('$pink<- C1 Horizontal Tabulation Set ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x90])) {
      // Start of a DCS sequence.
      controller.dcsStart = true;
      if (controller.verbose) {
        controller.log('$pink<- C1	Device Control String ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x9b])) {
      controller.csiStart = true;
      // 	Start of a CSI sequence.
      if (controller.verbose) {
        controller.log('$pink<- C1 Control Sequence Introducer ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x9c])) {
      // TODO
      if (controller.verbose) {
        controller.log('$pink<- C1 String Terminator ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x9d])) {
      controller.oscStart = true;
      if (controller.verbose) {
        controller.log('$pink<- C1 Operating System Command ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x9e])) {
      // TODO 不太清除实际的行为
      if (controller.verbose) {
        controller.log('$pink<- C1 Privacy Message ->');
      }
      return true;
    } else if (eq(utf8CodeUnits, [0xc2, 0x9f])) {
      // TODO
      if (controller.verbose) {
        controller.log('$pink<- C1 Application Program Comman ->');
      }
      return true;
    }
    return false;
  }
}
