import 'dart:async'; // For Timer functionality
import 'dart:io'; // For exit function

import 'package:flutter/material.dart'; // For building the UI
import 'package:intl/intl.dart'; // For formatting the date and time

// Import custom screen files
import 'screens/test_page.dart';
import 'screens/calibration_page.dart';
import 'screens/qc_page.dart';
import 'screens/log_page.dart';
import 'screens/system_page.dart';
import 'screens/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


 void main() {
   // Initialize FFI for desktop platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp()); // Start the Flutter application
}

// Main Application Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: MainScreen(), // Set MainScreen as the home page
    );
  }
}

// MainScreen Stateful Widget
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

// MainScreen State Class
class _MainScreenState extends State<MainScreen> {
  // *************** State Variables *****************
  int _selectedIndex = 0; // Tracks the currently selected page
  late Timer _timer; // Timer for updating time and date
  String _currentDate = ""; // Holds the current date
  String _currentTime = ""; // Holds the current time
  late List<Map<String, dynamic>> _menuItems; // Menu items for navigation

  // Page titles for AppBar
  final List<String> _pageTitles = [
    "Dashboard",
    "Test",
    "Result",
    "Calibration",
    "QC",
    "Log",
    "Setting"
  ];

  // ****************** InitState ******************
  @override
  void initState() {
    super.initState();

    // Initialize time and date updates
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _updateTime(); // Update time every second
    });

    // Initialize menu items dynamically
    _menuItems = [
      {
        'icon': Icons.science,
        'label': 'Test',
        'page': TestPage(onBackToMenu: _goToMenu) // Test Page
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Result',
        'page': ResultPage(onBackToMenu: _goToMenu) // Result Page
      },
      {
        'icon': Icons.build,
        'label': 'Calibration',
        'page': CalibrationPage(onBackToMenu: _goToMenu) // Calibration Page
      },
      {'icon': Icons.check_circle, 'label': 'QC', 'page': QCPage(onBackToMenu: _goToMenu)}, // QC Page
      {'icon': Icons.book, 'label': 'Log', 'page': LogPage(onBackToMenu: _goToMenu)}, // Log Page
      {
        'icon': Icons.settings,
        'label': 'System',
        'page': SystemPage(onBackToMenu: _goToMenu) // System Settings Page
      },
    ];
  }

  // **************** Update Time ****************
  void _updateTime() {
    final now = DateTime.now(); // Get the current time
    setState(() {
      _currentDate =
          DateFormat('EEEE, MMM d, yyyy').format(now); // Format current date
      _currentTime =
          DateFormat('hh:mm:ss a').format(now); // Format current time
    });
  }

  // ************** Navigate Back to Menu **************
  void _goToMenu() {
    setState(() {
      _selectedIndex = 0; // Reset to the main menu
    });
  }

  // ************** Show Shutdown Confirmation **************
  void _showShutdownDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Shutdown"), // Dialog title
          content: Text("Are you sure you want to shut down the application?"),
          actions: [
            // Cancel button
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            // Confirm button
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

  // ************** Build Selected Page **************
  Widget _buildSelectedPage(int selectedIndex) {
    if (selectedIndex == 0) {
      return buildGridMenu(); // Show grid menu
    }
    return _menuItems[selectedIndex - 1]['page']; // Navigate to selected page
  }

  // ************** Build Grid Menu **************
  Widget buildGridMenu() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Container(
          height: 800,
          width: 700,
          child: Center(
            child: GridView.builder(
              shrinkWrap: true, // Ensures the grid takes only as much space as needed
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                crossAxisSpacing: 35.0, // Spacing between columns
                mainAxisSpacing: 35.0, // Spacing between rows
              ),
              itemCount: _menuItems.length, // Number of menu items
              itemBuilder: (context, index) {
                final menuItem = _menuItems[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index + 1; // Navigate to the page
                    });
                  },
                  child: Column(
                    children: [
                      // Icon container
                      Container(
                        width: 200,
                        height: 170,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(233, 28, 61, 107),
                              Color(0xFF00706e)
                            ], // Gradient colors
                            begin: Alignment.topLeft ,stops: 
                             [0.0, 0.4],
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          menuItem['icon'], // Display menu icon
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      // Label
                      Text(
                        menuItem['label'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
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
      ),
    );
  }

  // ************** Dispose Resources **************
  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  // ************** Build UI **************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ************** AppBar **************
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App title
            Text(
              "HbA1c Analyzer",
              style: TextStyle(
                color: Color.fromARGB(139, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Center page title
            Expanded(
              child: Center(
                child: Text(
                  _pageTitles[_selectedIndex],
                  style: TextStyle(
                    foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        // AppBar gradient background
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 26, 57, 99),
                Color.fromARGB(255, 9, 78, 39)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Right-side actions
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentDate, // Current date
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      _currentTime, // Current time
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.power_settings_new),
                  onPressed: () {
                    _showShutdownDialog(context); // Show shutdown dialog
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
      // ************** Body **************
      body: _buildSelectedPage(_selectedIndex),
    );
  }
}
