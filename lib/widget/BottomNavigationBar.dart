
import 'dart:io';

import 'package:flutter/material.dart';
class CurvedBottomNavigationBar extends StatefulWidget {
  final VoidCallback onBackToMenu;

   final ValueNotifier<bool> wifiStatusNotifier;
   bool isStarted;

  CurvedBottomNavigationBar({super.key, required this.onBackToMenu, required this.wifiStatusNotifier, required this.isStarted});


  @override
  _CurvedBottomNavigationBarState createState() =>
      _CurvedBottomNavigationBarState();
}

class _CurvedBottomNavigationBarState extends State<CurvedBottomNavigationBar> {
  bool isWiFiEnabled = false; // WiFi state
  bool isCableConnected = false; // Cable state
  bool isBluetoothEnabled = false; // Bluetooth state

void initState() {
    super.initState();

    // Listen to WiFi status changes
    widget.wifiStatusNotifier.addListener(() {
      setState(() {}); // Trigger a rebuild to update the UI
    });
  }
  // Toggle WiFi state
  void toggleWiFi() {
    setState(() {
      isWiFiEnabled = !isWiFiEnabled;
    });
    print("WiFi ${isWiFiEnabled ? "Enabled" : "Disabled"}");
  }


  // Toggle Cable state
  void toggleCable() {
    setState(() {
      isCableConnected = !isCableConnected;
    });
    print("Cable ${isCableConnected ? "Connected" : "Disconnected"}");
  }

  // Toggle Bluetooth state
  void toggleBluetooth() {
    setState(() {
      isBluetoothEnabled = !isBluetoothEnabled;
    });
    print("Bluetooth ${isBluetoothEnabled ? "Enabled" : "Disabled"}");
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipPath(
          clipper: SoftEdgeCurveClipper(),
          child: Container(
            height: 50,
            width: 500,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color.fromARGB(172, 39, 104, 96),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // WiFi Icon
                IconButton(
                  icon: Icon(
                   widget.wifiStatusNotifier.value ? Icons.wifi : Icons.wifi,
                    color: Colors.white,
                  ),
                  onPressed: toggleWiFi,
                ),
                // Print Icon (Placeholder)
                Icon(
                  Icons.print_disabled,
                  color: Colors.white,
                ),
                SizedBox(width: 50), // Spacer
                // Cable Icon with Green/Red Dot
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cable,
                        color: Colors.white,
                      ),
                      onPressed: toggleCable,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isCableConnected ? Colors.green : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                // power Icon
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
        ),
        Positioned(
          top: -35,
          left: screenWidth / 2 - 35,
          child: GestureDetector(
    onTap: () {
      // Define your action here
      print("Home icon tapped");
      if(widget.isStarted == false){
        widget.onBackToMenu();
      }
     
      // You can navigate, show a dialog, or perform any other action here
    },
    child: CircleAvatar(
      radius: 35,
      backgroundColor: Color.fromARGB(183, 10, 74, 152),
      child: const Icon(
        Icons.home,
        size: 40,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    ),
  ),
        ),
      ],
    );
  }
}

class SoftEdgeCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;

     // Start from the bottom-left corner
    path.lineTo(width / 2 - 80, 0);

    // Add smooth bend at the start of the curve
    path.quadraticBezierTo(
      width / 2 - 60, 0,  // Control point (closer to the flat edge)
      width / 2 - 40, 20, // End point (higher on the curve)
    );

    // Draw a half-circle curve
    path.arcToPoint(
      Offset(width / 2 + 40, 20), // End point of the arc
      radius: Radius.circular(47), // Radius of the arc
      clockwise: false,
    );

    // Add smooth bend at the end of the curve
    path.quadraticBezierTo(
      width / 2 + 60, 0,  // Control point (mirrored on the opposite side)
      width / 2 + 80, 0, // End point (aligned with the flat edge)
    );

    // Complete the path
    path.lineTo(width, 0); // Move to the top-right corner
    path.lineTo(width, height); // Bottom-right corner
    path.lineTo(0, height); // Bottom-left corner
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
