import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/termare_view.dart';

// 考虑用 callback
// 只针对终端模拟器设计的滑动视图
class ScrollViewTerm extends StatefulWidget {
  const ScrollViewTerm({
    Key? key,
    required this.controller,
    this.child,
  }) : super(key: key);
  final TermareController? controller;
  final Widget? child;

  @override
  _ScrollViewTermState createState() => _ScrollViewTermState();
}

class _ScrollViewTermState extends State<ScrollViewTerm>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  double curOffset = 0;
  bool onPanUpdate = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          // print('x: ${event.position.dx}, y: ${event.position.dy}');
          // print('scroll delta: ${event.scrollDelta}');

          curOffset -= event.scrollDelta.dy;
          final int scrollLine = -curOffset.toInt() ~/
              widget.controller!.theme!.characterHeight!.toInt();
          // print('scrollLine -> $scrollLine');
          if (scrollLine != 0) {
            widget.controller!.currentBuffer!.scroll(scrollLine);
            curOffset = 0;
            widget.controller!.notifyListeners();
          }
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: (details) {
          onPanUpdate = true;
          curOffset = 0;
        },
        onPanUpdate: (details) {
          // 手在滑动的时候禁止自动滚动
          widget.controller!.disableAutoScroll();
          // 下一帧标记为脏
          widget.controller!.needBuild();
          curOffset += details.delta.dy;

          final int scrollLine = -curOffset.toInt() ~/
              widget.controller!.theme!.characterHeight!.toInt();
          // print('scrollLine -> $scrollLine');
          if (scrollLine != 0) {
            widget.controller!.currentBuffer!.scroll(scrollLine);
            curOffset = 0;
            widget.controller!.notifyListeners();
          }
        },
        onPanEnd: (details) {
          onPanUpdate = false;
          widget.controller!.needBuild();
          final double velocity =
              1.0 / (0.050 * WidgetsBinding.instance!.window.devicePixelRatio);
          final double distance =
              1.0 / WidgetsBinding.instance!.window.devicePixelRatio;
          final Tolerance tolerance = Tolerance(
            velocity: velocity, // logical pixels per second
            distance: distance, // logical pixels
          );
          final double start = curOffset;
          final ClampingScrollSimulation clampingScrollSimulation =
              ClampingScrollSimulation(
            position: start,
            velocity: details.velocity.pixelsPerSecond.dy,
            tolerance: tolerance,
          );
          animationController = AnimationController(
            vsync: this,
            value: 0,
            lowerBound: double.negativeInfinity,
            upperBound: double.infinity,
          );
          animationController.reset();
          animationController.addListener(() {
            if (onPanUpdate) {
              // curOffset = 0;
              return;
            }
            final double shouldOffset = animationController.value - curOffset;

            widget.controller!.needBuild();
            final int scrollLine = -shouldOffset.toInt() ~/
                widget.controller!.theme!.characterHeight!.toInt();
            // print('scrollLine -> $scrollLine');
            if (scrollLine != 0) {
              widget.controller!.currentBuffer!.scroll(scrollLine);
              curOffset = animationController.value;
              widget.controller!.notifyListeners();
            }
          });
          animationController.animateWith(clampingScrollSimulation);
        },
        child: widget.child,
      ),
    );
  }
}
