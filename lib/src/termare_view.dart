import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/src/core/text_attributes.dart';
import 'package:termare_view/src/widget/input_listener.dart';
import 'package:termare_view/src/termare_controller.dart';

import 'painter/termare_painter.dart';
import 'core/term_size.dart';
import 'theme/term_theme.dart';
import 'utils/keyboard_handler.dart';
import 'widget/scroll_view.dart';

class TermareView extends StatefulWidget {
  const TermareView({
    Key key,
    this.controller,
    this.keyboardInput,
    this.onTextInput,
    this.onKeyStroke,
    this.onAction,
    this.onBell,
  }) : super(key: key);
  final TermareController controller;
  final KeyboardInput keyboardInput;
  final InputHandler onTextInput;
  final KeyStrokeHandler onKeyStroke;
  final ActionHandler onAction;
  // 触发响铃会回调这个函数
  final void Function() onBell;
  static TermSize getTermSize(Size size) {
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.characterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.characterWidth;
    return TermSize(row, column);
  }

  @override
  _TermareViewState createState() => _TermareViewState();
}

class _TermareViewState extends State<TermareView> {
  final FocusNode _focusNode = FocusNode();
  KeyboardHandler keyboardHandler;
  Size painterSize = const Size(0, 0);
  // 记录键盘高度
  double keyoardHeight = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.onBell = widget.onBell;
    keyboardHandler = KeyboardHandler();
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
      if (widget.controller.ctrlEnable) {
        firstChar -= 96;
        widget.controller.enbaleOrDisableCtrl();
      }
      codeUnits.first = firstChar;
      widget.keyboardInput(utf8.decode(codeUnits));
    } else if (value.text.length < initEditingState.text.length) {
      // 说明删除了字符
      widget.keyboardInput(String.fromCharCode(127));
    } else {
      // 当字符长度相等，就存在光标移动问题
      if (value.selection.baseOffset < 1) {
        widget.keyboardInput(String.fromCharCode(2));
      } else if (value.selection.baseOffset > 1) {
        widget.keyboardInput(String.fromCharCode(6));
      }
    }

    return initEditingState;
  }

  @override
  Widget build(BuildContext context) {
    return InputListener(
      focusNode: _focusNode,
      onTextInput: (TextEditingValue value) {
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          return null;
        }
        return onTextEdit(
          value,
        );
      },
      onAction: (TextInputAction action) {
        if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          return null;
        }
        // 当软件盘回车按下的时候
        if (action == TextInputAction.done) {
          widget.keyboardInput('\n');
        }
        widget?.onAction?.call(action);
      },
      onKeyStroke: (RawKeyEvent key) {
        // 26键盘之外的按键按下的时候
        final String input = keyboardHandler.getKeyEvent(key);
        if (input != null) {
          if (widget.controller.ctrlEnable) {
            final int charCode = utf8.encode(input).first;
            widget.keyboardInput(utf8.decode([charCode - 96]));
            widget.controller.ctrlEnable = false;
          } else {}
          widget.keyboardInput(input);
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
                InputListener.of(context).requestKeyboard();
              }
            },
            child: ScrollViewTerm(
              controller: widget.controller,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return TerminalView(
                    painterSize: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    controller: widget.controller,
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

class TerminalView extends StatefulWidget {
  const TerminalView({
    Key key,
    @required this.painterSize,
    @required this.controller,
  }) : super(key: key);

  final Size painterSize;
  final TermareController controller;
  @override
  _TerminalViewState createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    resizeWindow();
    widget.controller.addListener(updateTerm);
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // double keyoardHeight = MediaQuery.of(context).viewInsets.bottom;
      // print('keyoardHeight -> $keyoardHeight');
      // print('$this resizeWindow');
      widget.controller.setPtyWindowSize(widget.painterSize);
      // print(widget.painterSize);

      widget.controller.autoScroll = true;
      widget.controller.dirty = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(updateTerm);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('$this build');
    return CustomPaint(
      size: widget.painterSize,
      painter: TermarePainter(
        controller: widget.controller,
      ),
    );
  }
}
