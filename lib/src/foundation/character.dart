import 'text_attribute.dart';

/// 用来描述每一个在终端上绘制的字符的属性
class Character {
  Character({
    this.textAttributes,
    this.wcwidth = 1,
    required this.content,
  });

  String content;
  // 这个不是dx或者px的字体宽度，是字符应该在终端中占有的宽度，即格子数
  final int wcwidth;
  final TextAttribute? textAttributes;
  bool get isEmpty => content == ' ';

  @override
  String toString() {
    return 'content:$content';
  }
}
