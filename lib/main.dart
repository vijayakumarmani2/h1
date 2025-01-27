import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hba1c_analyzer_1/screens/welcomepage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Flutter Fullscreen App');
    setWindowFrame(Rect.fromLTWH(0, 0, 1280, 800)); // Set the default size (e.g., fullscreen 1920x1080)
  }
  // Initialize FFI for desktop platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}