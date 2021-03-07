import 'dart:math';
import 'package:termare_view/src/core/letter_eneity.dart';
import 'package:termare_view/src/termare_controller.dart';

class Buffer {
  Buffer(this.controller) {
    viewRows = controller.row;
  }
  final TermareController controller;
  List<List<Character>> cache = [];
  int _position = 0;
  int get position => _position;
  int viewRows;
  // 这是默认的limit，在 	CSI Ps ; Ps r 这个序列后，可滑动的视口会变化
  int get limit => _position + viewRows;
  int maxLine = 1000;
  int get length => cache.length;
  void clear() {
    cache.clear();
  }

  void setViewPoint(int rows) {
    viewRows = rows;
  }

  int absoluteLength() {
    final int endRow = cache.length - 1;
    // print('cache.length -> ${cache.length}');
    for (int row = endRow; row > 0; row--) {
      final List<Character> line = cache[row];
      if (line == null || line.isEmpty) {
        continue;
      }
      for (Character character in line) {
        final bool isNotEmpty = character?.content?.isNotEmpty;
        if (isNotEmpty != null && isNotEmpty) {
          // print(
          //     'row + 1:${row + 1} currentPointer.y + 1 :${currentPointer.y + 1}');
          return max(row + 1, controller.currentPointer.y + 1);
        }
      }
    }
    return controller.currentPointer.y;
  }

  void write(int row, int column, Character entity) {
    // print(
    //     'write row:$row length:$length column:$column $entity position:$position');

    if (row > length - 1) {
      // 防止在row上越界
      cache.length = row + 1;
      cache[row] = [];
    }
    if (cache[row] == null) {
      // 有可能存在[null,null]，这个index能取到值，但是为null
      cache[row] = [];
    }
    if (column > cache[row].length - 1) {
      // 防止在 column 上越界
      cache[row].length = column + 1;
    }
    cache[row][column] = entity;
    // printBuffer();
  }

  void printBuffer() {
    for (int row = 0; row < controller.row; row++) {
      // print(lines);
      // print(getCharacterLines(row));
      String line = '$row:';
      for (int column = 0; column < controller.column; column++) {
        final Character character = getCharacter(row, column);
        if (character == null) {
          line += ' ';
          continue;
        }
        line += character.content;
      }
      print('->$line<-');
    }
  }

  Character getCharacter(
    int row,
    int column,
  ) {
    // print('getCharacter $row $column $length');
    if (row + _position > length - 1) {
      cache.length = row + _position + 1;
      cache[row + _position] = [];
    }
    final List<Character> lines = getCharacterLines(row);
    if (column > lines.length - 1) {
      lines.length = column + _position + 1;
    }
    return lines[column];
  }

  List<Character> getCharacterLines(
    int row,
  ) {
    if (row + _position > length - 1) {
      cache.length = row + _position + 1;
      cache[row + _position] = [];
    }
    if (cache[row + _position] == null) {
      cache[row + _position] = [];
    }
    return cache[row + _position];
  }

  void scroll(int line) {
    // print(absoluteLength());
    _position += line;
    // _position = max(0, _position);
    if (absoluteLength() > viewRows) {
      _position = min(absoluteLength() - viewRows, _position);
      _position = max(0, _position);
    } else {
      _position = 0;
    }
    // print('_position -> $_position');
  }
}
