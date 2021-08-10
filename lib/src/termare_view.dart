import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/src/termare_controller.dart';
import 'package:termare_view/src/widget/input_listener.dart';
import 'input/key_handler.dart';
import 'painter/termare_painter.dart';
import 'utils/platform/platform.dart';
import 'utils/signale/signale.dart';
import 'widget/scroll_view.dart';

class TermareView extends StatefulWidget {
  const TermareView({
    Key? key,
    this.controller,
    this.keyboardInput,
    this.onTextInput,
    this.onKeyStroke,
    this.onAction,
  }) : super(key: key);
  final TermareController? controller;
  final KeyboardInput? keyboardInput;
  final InputHandler? onTextInput;
  final KeyStrokeHandler? onKeyStroke;
  final ActionHandler? onAction;

  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView> {
  final FocusNode _focusNode = FocusNode();
  Size painterSize = const Size(0, 0);
  // 记录键盘高度
  double keyoardHeight = 0;
  late TermareController controller;
  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TermareController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        controller.requestFocus();
      } else {
        controller.unFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  final initEditingState = const TextEditingValue(
    text: '  ',
    selection: TextSelection.collapsed(offset: 1),
  );
  TextEditingValue onTextEdit(
    TextEditingValue value,
  ) {
    if (value.text.length > initEditingState.text.length) {
      final String input = value.text.substring(1, value.text.length - 1);
      final List<int> codeUnits = utf8.encode(input);

      int firstChar = codeUnits.first;
      if (widget.controller!.ctrlEnable) {
        firstChar -= 96;
        widget.controller!.enbaleOrDisableCtrl();
      }
      codeUnits.first = firstChar;
      widget.keyboardInput!(utf8.decode(codeUnits));
    } else if (value.text.length < initEditingState.text.length) {
      // 说明删除了字符
      widget.keyboardInput!(String.fromCharCode(127));
    } else {
      // 当字符长度相等，就存在光标移动问题
      Log.i('光标移动问题 ${value.selection.baseOffset}');
      if (value.selection.baseOffset < 1) {
        widget.keyboardInput!(String.fromCharCode(2));
      } else if (value.selection.baseOffset > 1) {
        widget.keyboardInput!(String.fromCharCode(6));
      }
    }

    return initEditingState;
  }

  /// 这个函数存在的意义就是
  /// 在移动端，并且外接键盘的情况下，按下回车键会同时触发keyboard和action
  /// 会导致输入两次换行
  void preventAction(String char) {
    preventChar = char;
    Future<void>.delayed(Duration(milliseconds: 100), () {
      preventChar = '';
    });
  }

  String preventChar = '';
  @override
  Widget build(BuildContext context) {
    return InputListener(
      focusNode: _focusNode,
      onTextInput: (TextEditingValue value) {
        // Log.i(value);
        if (TermarePlatform.isDesktop) {
          // return onTextEdit(
          //   value,
          // );
          return null;
        }
        return onTextEdit(
          value,
        );
      },
      onAction: (TextInputAction action) {
        if (TermarePlatform.isDesktop) {
          return;
        }
        // 当软件盘回车按下的时候
        if (action == TextInputAction.done) {
          if (preventChar != '\r') {
            Log.e('回车');
            widget.keyboardInput!('\r');
          }
        }
        widget.onAction?.call(action);
      },
      onKeyStroke: (RawKeyEvent key) {
        // Log.i(key);
        // 26键盘之外的按键按下的时候
        final int keyId = key.logicalKey.keyId;
        if (key is RawKeyDownEvent) {
          final String? input = KeyHandler.getCode(
            keyId,
            0,
            true,
            false,
          );
          // 100毫秒阻止同个按键的action触发
          preventAction(input!);
          Log.e('输入${input.codeUnits}');
          if (key.logicalKey == LogicalKeyboardKey.controlLeft ||
              key.logicalKey == LogicalKeyboardKey.controlRight) {
            // 当左边的ctrl或者右边的ctrl按下的时候
            widget.controller!.ctrlEnable = true;
          }
          if (input != null) {
            if (widget.controller!.ctrlEnable) {
              final int charCode = utf8.encode(input).first;
              widget.keyboardInput!(utf8.decode([charCode - 96]));
              // 这儿这个取消有问题，物理键盘按下的时候，输入字符不会触发CTRL的抬起
              widget.controller!.ctrlEnable = false;
            } else {
              widget.keyboardInput!(input);
            }
          }
        }
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () async {
              // widget.onDoubleTap?.call();
            },
            onTap: () {
              if (widget.keyboardInput != null) {
                InputListener.of(context)!.requestKeyboard();
              }
            },
            child: ScrollViewTerm(
              controller: controller,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _TerminalView(
                    painterSize: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    controller: controller,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// 封装了一层，避免一个widget内部太复杂
class _TerminalView extends StatefulWidget {
  const _TerminalView({
    Key? key,
    required this.painterSize,
    required this.controller,
  }) : super(key: key);

  final Size painterSize;
  final TermareController controller;
  @override
  _TerminalViewState createState() => _TerminalViewState();
}

class _TerminalViewState extends State<_TerminalView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    resizeWindow();
    widget.controller.addListener(updateTerm);
    WidgetsBinding.instance!.addObserver(this);
  }

  void updateTerm() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    resizeWindow();
  }

  void resizeWindow() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.controller.setWindowSize(widget.painterSize);
      // print(widget.painterSize);
      widget.controller.execAutoScroll();
      widget.controller.needBuild();
      widget.controller.notifyListeners();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    widget.controller.removeListener(updateTerm);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('$this build');
    return Material(
      color: widget.controller.theme!.backgroundColor,
      child: CustomPaint(
        size: widget.painterSize,
        painter: TermarePainter(
          controller: widget.controller,
        ),
      ),
    );
  }
}
