import 'dart:math';
import 'package:termare_view/src/core/character.dart';
import 'package:termare_view/src/termare_controller.dart';
import 'package:termare_view/src/utils/custom_log.dart';

class Buffer {
  Buffer(this.controller) {
    viewRows = controller.row;
  }
  final TermareController controller;
  List<List<Character?>> cache = [];
  int _position = 0;
  int get position => _position;
  int? viewRows;
  // 这是默认的limit，在 	CSI Ps ; Ps r 这个序列后，可滑动的视口会变化
  int get limit => _position + viewRows!;
  int maxLine = 1000;
  bool isCsiR = false;
  int get length => cache.length;

  // 在 csi r 序列到来时，
  Map<int, List<Character?>> fixedLine = {};
  void clear() {
    cache.clear();
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! Buffer) {
      return false;
    }
    if (other is Buffer) {
      return other.hashCode == hashCode;
    }
    return false;
  }

  @override
  int get hashCode => cache.hashCode;
  void setViewPoint(int rows) {
    // print('setViewPoint -> $rows');
    viewRows = rows;
    if (rows != controller.row) {
      Log.i('开始缓存');
      for (int i = rows; i < controller.row; i++) {
        // print('缓存第${i + 1}行');
        fixedLine[i] = [];
        fixedLine[i]!.length = controller.row;
        // String line = '';
        // for (int column = 0; column < controller.column; column++) {
        //   final Character character = getCharacter(i, column);
        //   if (character == null) {
        //     line += ' ';
        //     continue;
        //   }
        //   line += character.content;
        // }
        // print('这行->$line');
      }
      // for (int i = rows; i < controller.row; i++) {
      //   cache.removeAt(rows);
      // }
    } else {
      fixedLine.clear();
    }
  }

  int absoluteLength() {
    final int endRow = cache.length - 1;
    // print('cache.length -> ${cache.length}');
    for (int row = endRow; row > 0; row--) {
      final List<Character?> line = cache[row];
      if (line == null || line.isEmpty) {
        continue;
      }
      for (final Character? character in line) {
        final bool? isNotEmpty = character?.content?.isNotEmpty;
        if (isNotEmpty != null && isNotEmpty) {
          // print(
          //     'row + 1:${row + 1} currentPointer.y + 1 :${currentPointer.y + 1}');
          return max(row + 1, controller.currentPointer.y + 1);
        }
      }
    }
    return controller.currentPointer.y;
  }

  int getRowLength(int row) {
    final List<Character?> line = getCharacterLines(row)!;
    final int endColumn = line.length - 1;
    for (int column = endColumn; column > 0; column--) {
      final Character? character = line[column];
      final bool? isNotEmpty = character?.content?.isNotEmpty;
      if (isNotEmpty != null && isNotEmpty) {
        // print('$character ${column + 1}');
        return column + 1;
      }
    }
    return 0;
  }

  void write(int row, int column, Character? entity) {
    if (row >= maxLine) {
      // TODO 有问题，不用怀疑
      // print('ro - max ${row - maxLine}');
      cache = List.from(cache.getRange(1, maxLine));
      row = maxLine - 1;
      controller.moveToRelativeRow(-1);
      _position -= 1;
    }
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
    if (fixedLine.containsKey(row - position)) {
      fixedLine[row - position]![column] = entity;
      isCsiR = false;
      for (int i = row - position; i < controller.row; i++) {
        String line = '';
        for (int column = 0; column < controller.column; column++) {
          final Character? character = getCharacter(i, column);
          if (character == null) {
            line += ' ';
            continue;
          }
          line += character.content;
        }
        Log.i('写入固定行${row - position} 行内内容->$line');
      }
    } else {
      cache[row][column] = entity;
    }
    // printBuffer();
  }

  void printBuffer() {
    for (int row = 0; row < controller.row; row++) {
      // print(lines);
      // print(getCharacterLines(row));
      String line = '$row:';
      for (int column = 0; column < controller.column; column++) {
        final Character? character = getCharacter(row, column);
        if (character == null) {
          line += ' ';
          continue;
        }
        line += character.content;
      }
      Log.i('->$line<-');
    }
  }

  Character? getCharacter(
    int row,
    int column,
  ) {
    // print('getCharacter $row $column $length');
    if (row + _position > length - 1) {
      cache.length = row + _position + 1;
      cache[row + _position] = [];
    }
    final List<Character?> lines = getCharacterLines(row)!;
    if (column > lines.length - 1) {
      lines.length = column + _position + 1;
    }
    return lines[column];
  }

  List<Character?>? getCharacterLines(
    int row,
  ) {
    if (fixedLine.isNotEmpty && fixedLine.containsKey(row)) {
      return fixedLine[row];
    }
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
    if (absoluteLength() > viewRows!) {
      if (viewRows != controller.row) {
        // print('!!!!!');
        // final tmp = cache[limit - 2];
        // print('tmp[0].content ->${tmp[0].content}${tmp[1].content}');
        // // final tmp2 = cache[limit - 1];
        // // print('tmp[0].content ->${tmp2[0].content}${tmp2[1].content}');
        // cache[limit - 2] = cache[limit - 1];
        // cache[limit - 1] = tmp;
      }
      _position = min(absoluteLength() - viewRows!, _position);
      _position = max(0, _position);
    } else {
      _position = 0;
    }
    // print('_position -> $_position');
  }
}
