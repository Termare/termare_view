import 'dart:convert';

void main() {
  // print('\n'.codeUnits);
  // print(utf8.decode(<int>[27]));
  // print(utf8.decode(<int>[91]));
  print(utf8.decode(<int>[63]));
  print(utf8.encode('D'));
  print('${'a' * 75}\x0dbbb\n');
  print('\x7f'.codeUnits);
  print(utf8.decode(<int>[128]));
}
