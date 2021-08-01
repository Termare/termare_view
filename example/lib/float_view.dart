import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class FloatView extends StatefulWidget {
  const FloatView({
    Key key,
    this.child,
    this.initOffset,
    this.useAnimation = true,
  }) : super(key: key);
  final Widget child;
  final bool useAnimation;
  final Offset initOffset;

  @override
  _FloatViewState createState() => _FloatViewState();
}

class _FloatViewState extends State<FloatView> {
  Offset offset = Offset(0, 0);
  BuildContext childContext;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          offset += details.delta;

          setState(() {});
        },
        child: Builder(
          builder: (_) {
            childContext ??= _;
            return widget.child;
          },
        ),
      ),
    );
  }
}
