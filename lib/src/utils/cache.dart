import 'package:flutter/painting.dart';
import 'package:quiver/collection.dart';

class TextLayoutCache {
  TextLayoutCache(this.textDirection, int maximumSize)
      : _cache = LruMap<TextSpan, TextPainter>(maximumSize: maximumSize);
  final LruMap<TextSpan, TextPainter> _cache;
  final TextDirection textDirection;

  TextPainter getOrPerformLayout(TextSpan text) {
    final cachedPainter = _cache[text];
    if (cachedPainter != null) {
      return cachedPainter;
    } else {
      return _performAndCacheLayout(text);
    }
  }

  TextPainter _performAndCacheLayout(TextSpan text) {
    final textPainter = TextPainter(
        text: text, textDirection: textDirection, textAlign: TextAlign.center);
    textPainter.layout();

    _cache[text] = textPainter;

    return textPainter;
  }
}
