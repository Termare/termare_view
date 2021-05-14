// 简单的包含x,y的封装
class Position {
  Position(this.x, this.y);

  /// 终端字符在x轴的位置
  int x;

  /// 终端字符在y轴的位置
  int y;

  double get dx => x.toDouble();

  double get dy => y.toDouble();

  @override
  String toString() {
    return '< x:$x y:$y>';
  }

  void moveTo(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
