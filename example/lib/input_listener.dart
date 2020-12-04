import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

typedef OnKey = void Function(RawKeyEvent);

class InputListener extends StatefulWidget {
  const InputListener({
    Key key,
    @required this.child,
    this.onkey,
    @required this.focusNode,
  }) : super(key: key);
  final Widget child;
  final OnKey onkey;
  final FocusNode focusNode;
  @override
  _InputListenerState createState() => _InputListenerState();
}

class _InputListenerState extends State<InputListener> {
  FocusAttachment _focusAttachment;

  bool _didAutoFocus = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusAttachment = focusNode.attach(context);
    focusNode.addListener(onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');

    if (!_didAutoFocus && true) {
      _didAutoFocus = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).autofocus(focusNode);
        }
      });
    }
  }

  @override
  void didUpdateWidget(InputListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('${focusNode}');
    print('didUpdateWidget');
    // if (focusNode != oldWidget.focusNode) {
    //   oldWidget.focusNode.removeListener(onFocusChange);
    //   _focusAttachment?.detach();
    //   _focusAttachment = focusNode.attach(context);
    //   focusNode.addListener(onFocusChange);
    // }
  }

  void onFocusChange() {
    print('focusNode.onFocusChange -> ${focusNode.hasFocus}');
  }

  @override
  void dispose() {
    print('$this dispose');
    // focusNode.unfocus();
    _focusAttachment.detach();
    // focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    return Stack(
      children: [
        RawKeyboardListener(
          onKey: widget.onkey,
          focusNode: focusNode,
          child: widget.child,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            onPressed: () {
              focusNode.requestFocus();

              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
              print(widget.focusNode.canRequestFocus);
              print(widget.focusNode.offset);
              // widget.focusNode.requestFocus();
              // _focusAttachment.detach();
              // widget.focusNode.attach(context);
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   debugDumpFocusTree();
              // });
              print(FocusManager.instance.primaryFocus);
              // print(widget.focusNode.attach(context).reparent());
            },
            child: Text(
              '按钮',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
