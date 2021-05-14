import 'dart:convert';

// void print(Object object) {
//   stdout.write(object);
// }

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
  print(utf8.decode([10, 27, 107, 108, 115, 27, 92, 97]));
}
