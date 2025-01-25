import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/screens/menu_page.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/services/serial_port_service.dart';


class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade-in animation
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      initializeSerialReader(); // Prints after 1 second.
    });
  }

  void logEvent(String type, String message, {required String page}) async {
    await DatabaseHelper.instance.logEvent(type, message, page: page);
    print("$type: $message");
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initializeSerialReader() {
    logEvent('info', 'Serial reader initialization started.',
        page: 'welcome_page');
    var serialReader = SerialReader('/dev/ttyUSB-static');
    // serialReader = SerialReader('COM5');
    if (!serialReader.init()) {
      print(
          'Failed to open serial port /dev/ttyUSB-static. Please check the connection.');
      // Show a SnackBar if the maximum limit is reached
      logEvent('error',
          'Failed to open serial port /dev/ttyUSB-static. Please check the connection.',
          page: 'welcome_page');

      print('Failed to open serial port. Please check the connection.');
    } else {
      logEvent('info', 'Serial reader initialized successfully.',
          page: 'welcome_page');
       
  
      final message = "INITS"; // Example message format
      serialReader.port?.write(Uint8List.fromList(message.codeUnits));
      Future.delayed(Duration(seconds: 2), () {
  print("This is executed after a 2-second delay");
});
      serialReader.port?.write(Uint8List.fromList(message.codeUnits));
      print("Sent to hardware: $message");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('sent to hardware: $message'),
          duration: Duration(seconds: 2),
        ),
      );
    
     String buffer = '';

      serialReader.getStream()!.listen((data) {
        // Append received data to the buffer
        
        buffer += String.fromCharCodes(data);
        print("buffer: $buffer");
        if (buffer == "INI_CMPT") {
          print("Initialization completed - ${buffer}");
          logEvent('info', 'Initialization completed - ${buffer}',
          page: 'welcome_page');
          _navigateToHome();
          buffer = '';
          serialReader.port?.close();
        }
        // Extract data between `<` and `>` and add to the queue
        // while (buffer.contains('<') && buffer.contains('>')) {
        //   final start = buffer.indexOf('<');
        //   final end = buffer.indexOf('>', start);
        //   if (end > start) {
        //     if (buffer.substring(start + 1, end).contains("INI_CMPT")) {
        //       print(
        //           "Initialization complete-${buffer.substring(start + 1, end)}");
        //       serialReader.port?.close();
        //     }
        //     buffer = buffer.substring(end + 1);
        //   } else {
        //     break;
        //   }
        // }
      }, onError: (error) {
        print('Error reading serial port: $error');
        logEvent('error', 'Error reading serial port: $error',
            page: 'welcome_page');
      }, onDone: () {
        print('Serial port communication ended unexpectedly.');
        logEvent('warning', 'Serial port communication ended unexpectedly.',
            page: 'welcome_page');
      });
    }
  }


  // Simulated initialization process
  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2)); // Simulated delay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(onBackToMenu: () {  },),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF224c84), // Your first palette color
              Color.fromARGB(255, 51, 133, 77), // Your second palette color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star,
                    size: 100,
                    color: Colors.white, // Replace with your logo if needed
                  ),
                ),
                SizedBox(height: 20),
                // Welcome Text
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                 SizedBox(height: 30),
                Text(
                  "HbA1c Analyzer",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,
                    color: Color.fromARGB(148, 255, 255, 255),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Initializing the system.. Please wait.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                // Loading Animation
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFffffff)),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
