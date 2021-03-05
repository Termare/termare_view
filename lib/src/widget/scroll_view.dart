import 'package:flutter/material.dart';
import 'package:termare_view/termare_view.dart';

// 只针对终端模拟器设计的滑动视图
class ScrollViewTerm extends StatefulWidget {
  const ScrollViewTerm({
    Key key,
    @required this.controller,
    this.child,
  }) : super(key: key);
  final TermareController controller;
  final Widget child;

  @override
  _ScrollViewTermState createState() => _ScrollViewTermState();
}

class _ScrollViewTermState extends State<ScrollViewTerm>
    with TickerProviderStateMixin {
  AnimationController animationController;
  double curOffset = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (details) {
        curOffset = -widget.controller.startLength *
            widget.controller.theme.letterHeight;
      },
      onPanUpdate: (details) {
        // 手在滑动的时候禁止自动滚动
        widget.controller.autoScroll = false;
        // 下一帧标记为脏
        widget.controller.dirty = true;
        if (details.delta.dy > 0) {
          // 往下滑动
          curOffset += details.delta.dy;
          if (curOffset > 0) {
            curOffset = 0;
            return;
          }
          final int outLine = -curOffset.toInt() ~/
              widget.controller.theme.letterHeight.toInt();
          widget.controller.startLength = outLine;
        }
        if (details.delta.dy < 0) {
          // 往上滑动
          // 当内容满一个终端高度的时候
          if (widget.controller.absoluteLength() >
              widget.controller.rowLength) {
            curOffset += details.delta.dy;
            // 计算出偏移offset对应的行数
            int outLine = -curOffset ~/ widget.controller.theme.letterHeight;
            if (outLine + widget.controller.rowLength >
                widget.controller.absoluteLength()) {
              // 这个if内是限制向上滑动的时候，会停留在终端内容的最后一行
              outLine = widget.controller.absoluteLength() -
                  widget.controller.rowLength;
              curOffset = -outLine * widget.controller.theme.letterHeight;
            }
            widget.controller.startLength = outLine;
          }
        }
        widget.controller.notifyListeners();
      },
      onPanEnd: (details) {
        widget.controller.dirty = true;
        final double velocity =
            1.0 / (0.050 * WidgetsBinding.instance.window.devicePixelRatio);
        final double distance =
            1.0 / WidgetsBinding.instance.window.devicePixelRatio;
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
        final double pixelsPerSecondDy = details.velocity.pixelsPerSecond.dy;
        animationController.addListener(() {
          final double shouldOffset = animationController.value;
          widget.controller.dirty = true;
          // print('shouldOffset->$shouldOffset');
          if (pixelsPerSecondDy > 0) {
            // 往下滑动
            curOffset = shouldOffset;
            if (curOffset > 0) {
              // 代表视图滑动到顶部了
              curOffset = 0;
              animationController.stop();
            }
            final int outLine =
                -curOffset ~/ widget.controller.theme.letterHeight;
            widget.controller.startLength = outLine;
          }
          if (pixelsPerSecondDy < 0) {
            // 视图向上滚动
            // 只有当有效视图大于终端高度的时候才滚动
            if (widget.controller.absoluteLength() >
                widget.controller.rowLength) {
              curOffset = shouldOffset;
              int outLine = -curOffset ~/ widget.controller.theme.letterHeight;
              if (outLine + widget.controller.rowLength >
                  widget.controller.absoluteLength()) {
                // 做多往上滑动到输入光标上一个格子
                outLine = widget.controller.absoluteLength() -
                    widget.controller.rowLength;
                curOffset = -outLine * widget.controller.theme.letterHeight;
                animationController.stop();
              }
              widget.controller.startLength = outLine;
            }
          }

          widget.controller.notifyListeners();
        });
        animationController.animateWith(clampingScrollSimulation);
      },
      child: widget.child,
    );
  }
}
