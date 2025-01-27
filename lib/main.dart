import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hba1c_analyzer_1/screens/welcomepage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// Declare GTK functions

import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions options = WindowOptions(
    size: Size(1920, 1080),
    fullScreen: true,
  );
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setFullScreen(true);
    await windowManager.show();
  });

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