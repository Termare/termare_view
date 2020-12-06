// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';

// typedef OnKey = void Function(RawKeyEvent);

// typedef ActionHandler = void Function(TextInputAction);

// class InputListener extends StatefulWidget {
//   const InputListener({
//     Key key,
//     @required this.child,
//     this.onkey,
//     @required this.focusNode,
//   }) : super(key: key);
//   final Widget child;
//   final OnKey onkey;
//   final FocusNode focusNode;
//   @override
//   _InputListenerState createState() => _InputListenerState();
// }

// class _InputListenerState extends State<InputListener> {
//   FocusAttachment _focusAttachment;

//   ActionHandler onAction;
//   TextInputConnection _conn;
//   bool _didAutoFocus = false;
//   @override
//   void initState() {
//     super.initState();
//     _focusAttachment = widget.focusNode.attach(context);
//     widget.focusNode.addListener(onFocusChange);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     print('didChangeDependencies');

//     if (!_didAutoFocus && true) {
//       _didAutoFocus = true;
//       SchedulerBinding.instance.addPostFrameCallback((_) {
//         // if (mounted) {
//         //   FocusScope.of(context).autofocus(focusNode);
//         // }
//       });
//     }
//   }

//   @override
//   void didUpdateWidget(InputListener oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     print('${widget.focusNode}');
//     print('didUpdateWidget');
//     // if (focusNode != oldWidget.focusNode) {
//     //   oldWidget.focusNode.removeListener(onFocusChange);
//     //   _focusAttachment?.detach();
//     //   _focusAttachment = focusNode.attach(context);
//     //   focusNode.addListener(onFocusChange);
//     // }
//   }

//   bool get _shouldCreateInputConnection => kIsWeb;
//   void onInput(TextEditingValue value) {
//     // final newValue = widget.onTextInput(value);

//     // if (newValue != null) {
//     //   _conn?.setEditingState(newValue);
//     // }
//   }

//   bool get _hasInputConnection => _conn != null && _conn.attached;
//   void openInputConnection() {
//     print('_hasInputConnection->$_hasInputConnection');
//     if (!_shouldCreateInputConnection) {
//       return;
//     }
//     print('_hasInputConnection->$_hasInputConnection');
//     if (_hasInputConnection) {
//       _conn.show();
//     } else {
//       const TextInputConfiguration config = TextInputConfiguration();
//       final client = TerminalTextInputClient(onInput, onAction);
//       _conn = TextInput.attach(client, config);

//       _conn.show();

//       const double dx = 0.0;
//       const double dy = 0.0;
//       _conn.setEditableSizeAndTransform(
//         const Size(10, 10),
//         Matrix4.translationValues(dx, dy, 0.0),
//       );

//       _conn.setEditingState(TextEditingValue.empty);
//     }
//   }

//   void requestKeyboard() {
//     if (widget.focusNode.hasFocus) {
//       openInputConnection();
//     } else {
//       widget.focusNode.requestFocus();
//     }
//   }

//   void closeInputConnectionIfNeeded() {
//     if (_conn != null && _conn.attached) {
//       _conn.close();
//       _conn = null;
//     }
//   }

//   void onFocusChange() {
//     print('focusNode.onFocusChange -> ${widget.focusNode.hasFocus}');
//   }

//   @override
//   void dispose() {
//     print('$this dispose');
//     // focusNode.unfocus();
//     _focusAttachment.detach();
//     // focusNode.unfocus();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _focusAttachment.reparent();
//     return Stack(
//       children: [
//         RawKeyboardListener(
//           onKey: widget.onkey,
//           focusNode: widget.focusNode,
//           child: widget.child,
//         ),
//         Align(
//           alignment: Alignment.centerRight,
//           child: Row(
//             children: [
//               FlatButton(
//                 onPressed: () {
//                   openInputConnection();
//                   // requestKeyboard();
//                   // SystemChannels.textInput.invokeMethod<void>('TextInput.show');
//                   // print(widget.focusNode.canRequestFocus);
//                   // print(widget.focusNode.offset);
//                   // // widget.focusNode.requestFocus();
//                   // // _focusAttachment.detach();
//                   // // widget.focusNode.attach(context);
//                   // // WidgetsBinding.instance.addPostFrameCallback((_) {
//                   // //   debugDumpFocusTree();
//                   // // });
//                   // print(FocusManager.instance.primaryFocus);
//                   // print(widget.focusNode.attach(context).reparent());
//                 },
//                 child: Text(
//                   '获取焦点',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () {
//                   widget.focusNode.requestFocus();

//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   '返回上一页',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class TerminalTextInputClient extends TextInputClient {
//   TerminalTextInputClient(this.onInput, this.onAction);

//   final void Function(TextEditingValue) onInput;
//   final ActionHandler onAction;

//   TextEditingValue _savedValue;

//   @override
//   TextEditingValue get currentTextEditingValue {
//     return _savedValue;
//   }

//   @override
//   AutofillScope get currentAutofillScope {
//     return null;
//   }

//   @override
//   void updateEditingValue(TextEditingValue value) {
//     // print('updateEditingValue $value');

//     onInput(value);

//     // if (_savedValue == null || _savedValue.text == '') {
//     //   onInput(value.text);
//     // } else if (_savedValue.text.length < value.text.length) {
//     //   final diff = value.text.substring(_savedValue.text.length);
//     //   onInput(diff);
//     // }

//     _savedValue = value;
//     // print('updateEditingValue $value');
//   }

//   @override
//   void performAction(TextInputAction action) {
//     // print('performAction $action');
//     onAction(action);
//   }

//   @override
//   void updateFloatingCursor(RawFloatingCursorPoint point) {
//     // print('updateFloatingCursor');
//   }

//   @override
//   void showAutocorrectionPromptRect(int start, int end) {
//     // print('showAutocorrectionPromptRect');
//   }

//   @override
//   void connectionClosed() {
//     // print('connectionClosed');
//   }

//   @override
//   void performPrivateCommand(String action, Map<String, dynamic> data) {
//     // print('performPrivateCommand $action');
//   }
// }
