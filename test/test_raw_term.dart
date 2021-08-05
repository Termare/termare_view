import 'dart:convert';

// void print(Object object) {
//   stdout.write(object);
// }
// ~ $ apt
// [8, 8, 8, 27, 91, 49, 80, 108, 115]
void main() {
  // for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m \e[0m" ; done ; echo

  // print('Application Program Command\x9fApplication Program Command');
  // for (int i = 0; i < 256; i++) {
  //   stdout.write('\x1b[48;5;$i\m$i     \x1b[0m');
  // }
  // csi ?2004l
  // for (int i = 0; i < 80; i++) {
  //   print('*');
  //   // print(i);
  // }
  print('123456\x08\x08\x08\x08\x08\x1b[3P99');
  print('123456\x08\x08\x08\x08\x08\x1b[3@999');
  var data = utf8.decode([8, 8, 8, 27, 91, 49, 80, 108, 115]);
  print('~ \$ pwd$data');
}
