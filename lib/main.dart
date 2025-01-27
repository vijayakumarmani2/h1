import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hba1c_analyzer_1/screens/welcomepage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Declare GTK functions
final gtk_window_set_decorated = DynamicLibrary.open('libgtk-3.so')
    .lookupFunction<Void Function(Pointer<Void>, Int32), void Function(Pointer<Void>, int)>('gtk_window_set_decorated');

final gtk_window_fullscreen = DynamicLibrary.open('libgtk-3.so')
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>('gtk_window_fullscreen');

// Modify the window
void configureWindow(Pointer<Void> windowPointer) {
  gtk_window_set_decorated(windowPointer, 0); // Remove decorations
  gtk_window_fullscreen(windowPointer);      // Fullscreen mode
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
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