import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/test_page.dart';
import 'screens/calibration_page.dart';
import 'screens/qc_page.dart';
import 'screens/log_page.dart';
import 'screens/system_page.dart';
import 'package:intl/intl.dart'; // For formatting the date and time
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TestPage(),
    CalibrationPage(),
    QCPage(),
    LogPage(),
    SystemPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

late Timer _timer;
  String _currentDate = "";
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _updateTime(); // Initialize the current time
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(now); // Format the date
    final formattedTime = DateFormat('hh:mm:ss a').format(now); // Format the time
    setState(() {
      _currentDate = "$formattedDate";
      _currentTime = "$formattedTime";
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HbA1c Analyzer",style: TextStyle(color: Color(0xFF00706e),fontWeight: FontWeight.bold,)),
        centerTitle: true,backgroundColor: Color.fromARGB(255, 254, 255, 255),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(192, 54, 54, 54),
                        ),
                      ),
                      Text(
                        _currentTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF224c84), // Hex code #224c84
              Color(0xFF0e7a3d), // Hex code #0e7a3d
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Allow the gradient to show through
          elevation: 0, // Remove shadow
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: 'Calibration',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'QC',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'System',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}