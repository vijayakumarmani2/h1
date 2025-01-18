import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
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
 final ValueNotifier<bool> wifiStatusNotifier = ValueNotifier(false);

  @override
  void dispose() {
    wifiStatusNotifier.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {

    final List<Widget> _pages = [
    WiFiConfigurationWidget(wifiStatusNotifier: wifiStatusNotifier,), // WiFi Section
    Center(child: Text('Print Settings')),
    Center(child: Text('Calibration Settings')),
    Center(child: Text('State Check Status')),
  ];

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
      
      bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu, wifiStatusNotifier:  wifiStatusNotifier,),
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
  





