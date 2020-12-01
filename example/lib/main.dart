import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'termare.dart';

void main() {
  runApp(
    MaterialApp(
      home: Termare(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}
