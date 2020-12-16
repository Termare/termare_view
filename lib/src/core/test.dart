import 'package:termare_view/src/core/safe_list.dart';

void main() {
  final SafeList<String> safeList = SafeList();
  print(safeList[0]);
  safeList[0] = '123';
  print(safeList[0]);
  print(safeList[1]);
  print(safeList[10000]);
  safeList[10000] = '123';
  print(safeList[10000]);
  final SafeList<SafeList<String>> safeList2 = SafeList<SafeList<String>>();
  safeList2[0] = SafeList();
  safeList2[0][0] = '1234';
}
