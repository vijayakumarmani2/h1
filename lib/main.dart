import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hba1c_analyzer_1/screens/menu_page.dart';
import 'package:hba1c_analyzer_1/screens/welcomepage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Declare GTK functions


void main() async {
 
  
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Color(0xFF224c84),
      ),
      body: Center(
        child: Text(
          "Home Page Content Here",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}