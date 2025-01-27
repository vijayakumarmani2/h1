import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hba1c_analyzer_1/screens/welcomepage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the window manager
  await windowManager.ensureInitialized();

  // Configure default window options
  WindowOptions windowOptions = WindowOptions(
    size: Size(1280, 800),       // Default size (optional)
    center: true,                // Center the window (optional)
    title: 'My App',             // Window title
    backgroundColor: Colors.transparent,
    skipTaskbar: false,          // Show the app in the taskbar
    titleBarStyle: TitleBarStyle.hidden, // Remove the title bar
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setFullScreen(true);   // Enable fullscreen
    await windowManager.setResizable(false);  // Disable resizing
    await windowManager.show();               // Show the window
    await windowManager.focus();              // Focus the window
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