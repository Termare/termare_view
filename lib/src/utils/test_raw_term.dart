import 'dart:io';

void main() {
  // for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m \e[0m" ; done ; echo

  // print('Application Program Command\x9fApplication Program Command');
  // for (int i = 0; i < 256; i++) {
  //   stdout.write('\x1b[48;5;$i\m$i     \x1b[0m');
  // }
  print('1234\x1b[3@4q');
}
