import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hba1c_analyzer_1/widget/wifi_configuration_widget.dart';


class SystemPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  SystemPage({required this.onBackToMenu});

  @override
  _SystemPageState createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  int _selectedIndex = 0;
   int _bottomNavIndex = 0;

  final List<Widget> _pages = [
    WiFiConfigurationWidget(), // WiFi Section
    Center(child: Text('Print Settings')),
    Center(child: Text('Calibration Settings')),
    Center(child: Text('State Check Status')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
  
        body: Row(
          children: [
            // Side tabs
            Container(
              width: 130, // Adjust as needed
              color: Colors.blue.shade100,
              child: ListView(
                children: [
                  _buildTabItem(Icons.wifi, 'WiFi', 0),
                  _buildTabItem(Icons.print, 'Print', 1),
                  _buildTabItem(Icons.build, 'Calibration', 2),
                  _buildTabItem(Icons.check_circle, 'State', 3),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      
        bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu),
      ),
    );
  }

  
  Widget _buildTabItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: _selectedIndex == index ? Colors.blue.shade300 : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: _selectedIndex == index ? Colors.white : Colors.black),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  
class CurvedBottomNavigationBar extends StatefulWidget {
  final VoidCallback onBackToMenu;

  CurvedBottomNavigationBar({required this.onBackToMenu});

  @override
  _CurvedBottomNavigationBarState createState() =>
      _CurvedBottomNavigationBarState();
}
    
  
  



class _CurvedBottomNavigationBarState extends State<CurvedBottomNavigationBar> {
  bool isWiFiEnabled = false; // WiFi state
  bool isCableConnected = false; // Cable state
  bool isBluetoothEnabled = false; // Bluetooth state

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
            decoration: BoxDecoration(
              color: Color.fromARGB(110, 2, 101, 80),
              borderRadius: const BorderRadius.only(
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
                    isWiFiEnabled ? Icons.wifi : Icons.wifi_off,
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
                          color: isCableConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                // Bluetooth Icon
                IconButton(
                  icon: Icon(
                    isBluetoothEnabled
                        ? Icons.bluetooth
                        : Icons.bluetooth_disabled,
                    color: Colors.white,
                  ),
                  onPressed: toggleBluetooth,
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
     widget.onBackToMenu();
      // You can navigate, show a dialog, or perform any other action here
    },
    child: CircleAvatar(
      radius: 35,
      backgroundColor: const Color.fromARGB(255, 10, 74, 152),
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

class PerfectHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;

    // Start from the bottom-left corner
    path.lineTo(width / 2 - 50, 0); // Move to the start of the curve
    path.arcToPoint(
      Offset(width / 2 + 50, 0), // End of the arc
      radius: Radius.circular(50), // Perfect half-circle radius
      clockwise: false,
    );
    path.lineTo(width, 0); // Move to the top-right corner
    path.lineTo(width, height); // Bottom-right corner
    path.lineTo(0, height); // Bottom-left corner
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
class BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;

    path.lineTo(width / 2 - 50, 0);
    path.quadraticBezierTo(
      width / 2 - 40,
      40,
      width / 2 - 30,
      40,
    );
    path.arcToPoint(
      Offset(width / 2 + 40, 20),
      radius: Radius.circular(40),
      clockwise: false,
    );
    path.quadraticBezierTo(
      width / 2 + 30,
      0,
      width / 2 + 30,
      0,
    );
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 0), // Adjust the bottom margin as needed
      alignment: Alignment.bottomCenter,
      child: Container(
        width: screenWidth / 2,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                // Add your action here
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Add your action here
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // Add your action here
              },
            ),
          ],
        ),
      ),
    );
  }
}