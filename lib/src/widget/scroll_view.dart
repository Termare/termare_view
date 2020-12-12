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
        print('onPanDown');
        curOffset =
            -widget.controller.startLine * widget.controller.theme.letterHeight;
      },
      onPanUpdate: (details) {
        widget.controller.autoScroll = false;
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
          widget.controller.startLine = outLine;
        }
        if (details.delta.dy < 0) {
          // 往上滑动
          // TODO
          // 当内容还没有满一个终端高度的时候
          if (widget.controller.cache.length > widget.controller.rowLength) {
            curOffset += details.delta.dy;

            int outLine =
                -curOffset ~/ widget.controller.theme.letterHeight.toInt();
            if (outLine + widget.controller.rowLength - 1 >
                widget.controller.cache.length) {
              outLine = widget.controller.cache.length -
                  widget.controller.rowLength +
                  1;
              curOffset = -outLine * widget.controller.theme.letterHeight;
            }
            widget.controller.startLine = outLine;
          }

          // PrintUtil.printD(
          //     'outLine->${widget.controller.startLine} ${widget.controller.cache.length} ${widget.controller.rowLength} ',
          //     [31]);
          // print('controller${widget.controller.currentPointer.dy - outLine}');

        }

        widget.controller.notifyListeners();
      },
      onPanEnd: (details) {
        final double pixelsPerSecondDy = details.velocity.pixelsPerSecond.dy;
        // return;
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
        animationController.addListener(() {
          final double shouldOffset = animationController.value;
          widget.controller.dirty = true;
          // print('shouldOffset->$shouldOffset');
          if (pixelsPerSecondDy > 0) {
            // 往下滑动

            curOffset = shouldOffset;
            if (curOffset > 0) {
              curOffset = 0;
              animationController.stop();
            }
            final int outLine =
                -curOffset ~/ widget.controller.theme.letterHeight;
            widget.controller.startLine = outLine;
          }
          if (pixelsPerSecondDy < 0) {
            if (widget.controller.cache.length > widget.controller.rowLength) {
              curOffset = shouldOffset;

              int outLine = -curOffset ~/ widget.controller.theme.letterHeight;
              if (outLine + widget.controller.rowLength - 1 >
                  widget.controller.cache.length) {
                // 做多往上滑动到输入光标上一个格子
                outLine = widget.controller.cache.length -
                    widget.controller.rowLength +
                    1;
                curOffset = -outLine * widget.controller.theme.letterHeight;
                animationController.stop();
              }
              widget.controller.startLine = outLine;
            }

            // PrintUtil.printD(
            //     'outLine->${widget.controller.startLine} ${widget.controller.cache.length} ${widget.controller.rowLength} ',
            //     [31]);
            // print('controller${widget.controller.currentPointer.dy - outLine}');

          }

          widget.controller.notifyListeners();
        });
        animationController.animateWith(clampingScrollSimulation);
      },
      child: widget.child,
    );
  }
}
