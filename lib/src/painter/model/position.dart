// 简单的包含x,y的封装
class Position {
  final int x;
  final int y;
  double get dx => x.toDouble();
  double get dy => y.toDouble();
  @override
  String toString() {
    return '< x:$x y:$y>';
  }

  Position(this.x, this.y);
}
