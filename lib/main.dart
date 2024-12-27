import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/screens/result.dart';
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

    // Initialize _menuItems dynamically in initState
    _menuItems = [
      {
        'icon': Icons.science,
        'label': 'Test',
        'page': TestPage(onBackToMenu: _goToMenu)
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Result',
        'page': ResultPage(onBackToMenu: _goToMenu)
      },
      {
        'icon': Icons.build,
        'label': 'Calibration',
        'page': CalibrationPage(onBackToMenu: _goToMenu)
      },
      {'icon': Icons.check_circle, 'label': 'QC', 'page': QCPage()},
      {'icon': Icons.book, 'label': 'Log', 'page': LogPage()},
      {
        'icon': Icons.settings,
        'label': 'System',
        'page': SystemPage(
          onBackToMenu: _goToMenu,
        )
      },
    ];
  }

  void _showShutdownDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Shutdown"),
          content: Text("Are you sure you want to shut down the application?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                exit(0); // Exit the application
              },
            ),
          ],
        );
      },
    );
  }

  // Menu items list
  late List<Map<String, dynamic>> _menuItems;

  void _updateTime() {
    final now = DateTime.now();
    final formattedDate =
        DateFormat('EEEE, MMM d, yyyy').format(now); // Format the date
    final formattedTime =
        DateFormat('hh:mm:ss a').format(now); // Format the time
    setState(() {
      _currentDate = "$formattedDate";
      _currentTime = "$formattedTime";
    });
  }

  void _goToMenu() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // Define titles for each page
  final List<String> _pageTitles = [
    "Dashboard",
    "Test",
    "Result",
    "Calibration",
    "QC",
    "Log",
    "Setting"
  ];

  Widget _buildSelectedPage(int selectedIndex) {
    switch (selectedIndex) {
      case 1:
        return TestPage(onBackToMenu: _goToMenu); // Pass the callback

      default:
        return buildGridMenu();
    }
  }

  Widget buildGridMenu() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Container(
          height: 700,
          width: 700,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 35.0,
              mainAxisSpacing: 35.0,
            ),
            padding: const EdgeInsets.all(20),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = _menuItems[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index + 1;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 170,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00706e),
                        gradient: const LinearGradient(
        colors: [ Color.fromARGB(255, 28, 61, 107),Color(0xFF00706e)], // Gradient colors
        begin: Alignment.topLeft, stops: [0.0, 0.5],// Gradient starting point
        end: Alignment.bottomRight, // Gradient ending point
      ),
                       
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        menuItem['icon'],
                        size: 60,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    Text(
                      menuItem['label'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00706e),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space out title and center text
          children: [
            // App title on the left
            Text(
              "HbA1c Analyzer",
              style: TextStyle(
                color: Color.fromARGB(139, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Center text
            Expanded(
              child: Center(
                child: Text(
                  _pageTitles[
                      _selectedIndex], // Replace with your desired center text
                  style: TextStyle(
                    color: Color.fromARGB(88, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [ Color.fromARGB(255, 26, 57, 99),Color.fromARGB(255, 9, 78, 39)], // Gradient colors
        begin: Alignment.topLeft, // Gradient starting point
        end: Alignment.bottomRight, // Gradient ending point
      ),
    ),
  ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(137, 218, 218, 218),
                        ),
                      ),
                      Text(
                        _currentTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons
                        .power_settings_new), // Icon for the shutdown button
                    onPressed: () {
                      _showShutdownDialog(context); // Show confirmation dialog
                    },
                    color: Color.fromARGB(169, 39, 24, 24),
                    iconSize: 30, // Color for shutdown icon
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? buildGridMenu()
          : _menuItems[_selectedIndex - 1]['page'],
    );
  }
}
