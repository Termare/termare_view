import 'dart:developer' as developer;

void main() {
  for (int i = 0; i < 256; i++) {
    print('\x1b[48;5;$i\m$i     \x1b[0m');
  }
  developer.log('value', name: 'GETX');
}
