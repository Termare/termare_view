import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

// copy 至 xterm.dart
typedef KeyStrokeHandler = void Function(RawKeyEvent);
typedef InputHandler = TextEditingValue Function(TextEditingValue);
typedef ActionHandler = void Function(TextInputAction);
typedef FocusHandler = void Function(bool);

abstract class InputListenerController {
  void requestKeyboard();
}

class InputListener extends StatefulWidget {
  const InputListener({
    @required this.child,
    @required this.onKeyStroke,
    @required this.onTextInput,
    @required this.onAction,
    @required this.focusNode,
    this.onFocus,
    this.autofocus = false,
    this.listenKeyStroke = true,
    this.readOnly = false,
    this.initEditingState = const TextEditingValue(
      text: '  ',
      selection: TextSelection.collapsed(offset: 1),
    ),
  });

  final Widget child;
  final InputHandler onTextInput;
  final KeyStrokeHandler onKeyStroke;
  final ActionHandler onAction;
  final FocusHandler onFocus;
  final bool autofocus;
  final FocusNode focusNode;
  final bool listenKeyStroke;
  final bool readOnly;
  final TextEditingValue initEditingState;

  @override
  InputListenerState createState() => InputListenerState();

  static InputListenerController of(BuildContext context) {
    return context.findAncestorStateOfType<InputListenerState>();
  }
}

class InputListenerState extends State<InputListener>
    implements InputListenerController {
  TextInputConnection _conn;
  FocusAttachment _focusAttachment;
  bool _didAutoFocus = false;

  @override
  void initState() {
    _focusAttachment = widget.focusNode.attach(context);
    widget.focusNode.addListener(onFocusChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didAutoFocus && widget.autofocus) {
      _didAutoFocus = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).autofocus(widget.focusNode);
        }
      });
    }
  }

  bool get _shouldCreateInputConnection => kIsWeb || !widget.readOnly;

  bool get _hasInputConnection => _conn != null && _conn.attached;

  @override
  void didUpdateWidget(InputListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(onFocusChange);
      _focusAttachment?.detach();
      _focusAttachment = widget.focusNode.attach(context);
      widget.focusNode.addListener(onFocusChange);
    }

    if (!_shouldCreateInputConnection) {
      closeInputConnectionIfNeeded();
    } else {
      if (oldWidget.readOnly && widget.focusNode.hasFocus) {
        openInputConnection();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusAttachment.detach();
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();

    if (widget.listenKeyStroke) {
      return RawKeyboardListener(
        focusNode: widget.focusNode,
        onKey: widget.onKeyStroke,
        autofocus: widget.autofocus,
        child: widget.child,
      );
    }

    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      includeSemantics: false,
      child: widget.child,
    );
  }

  @override
  void requestKeyboard() {
    if (widget.focusNode.hasFocus) {
      openInputConnection();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  void onFocusChange() {
    if (widget.onFocus != null) {
      widget.onFocus(widget.focusNode.hasFocus);
    }

    openOrCloseInputConnectionIfNeeded();
  }

  void openOrCloseInputConnectionIfNeeded() {
    if (widget.focusNode.hasFocus && widget.focusNode.consumeKeyboardToken()) {
      openInputConnection();
    } else if (!widget.focusNode.hasFocus) {
      closeInputConnectionIfNeeded();
    }
  }

  void openInputConnection() {
    if (!_shouldCreateInputConnection) {
      return;
    }

    if (_hasInputConnection) {
      _conn.show();
    } else {
      const TextInputConfiguration config = TextInputConfiguration();
      final client = TerminalTextInputClient(onInput, onAction);
      _conn = TextInput.attach(client, config);

      _conn.show();

      const double dx = 0.0;
      const double dy = 0.0;
      _conn.setEditableSizeAndTransform(
        const Size(10, 10),
        Matrix4.translationValues(dx, dy, 0.0),
      );

      _conn.setEditingState(widget.initEditingState);
    }
  }

  void closeInputConnectionIfNeeded() {
    if (_conn != null && _conn.attached) {
      _conn.close();
      _conn = null;
    }
  }

  void onInput(TextEditingValue value) {
    final newValue = widget.onTextInput(value);

    if (newValue != null) {
      _conn?.setEditingState(newValue);
    }
  }

  void onAction(TextInputAction action) {
    widget?.onAction(action);
  }
}

class TerminalTextInputClient extends TextInputClient {
  TerminalTextInputClient(this.onInput, this.onAction);

  final void Function(TextEditingValue) onInput;
  final ActionHandler onAction;

  TextEditingValue _savedValue;

  @override
  TextEditingValue get currentTextEditingValue {
    return _savedValue;
  }

  @override
  AutofillScope get currentAutofillScope {
    return null;
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    // print('updateEditingValue $value');

    onInput(value);

    // if (_savedValue == null || _savedValue.text == '') {
    //   onInput(value.text);
    // } else if (_savedValue.text.length < value.text.length) {
    //   final diff = value.text.substring(_savedValue.text.length);
    //   onInput(diff);
    // }

    _savedValue = value;
    // print('updateEditingValue $value');
  }

  @override
  void performAction(TextInputAction action) {
    // print('performAction $action');
    onAction(action);
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // print('updateFloatingCursor');
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // print('showAutocorrectionPromptRect');
  }

  @override
  void connectionClosed() {
    // print('connectionClosed');
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // print('performPrivateCommand $action');
  }
}
