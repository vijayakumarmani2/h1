import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/widget/primecheck.dart';
import 'package:hba1c_analyzer_1/widget/show_ip.dart';
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
   
    Center(child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Text('Hba1C Analyzer', style: TextStyle(fontSize: 24),),Text('V1.0.5', style: TextStyle(fontSize: 18),)
      ],
    ))), // About Section
     WiFiConfigurationWidget(wifiStatusNotifier: wifiStatusNotifier,), // WiFi Section
    IPDisplayScreen(), // IP Address Section
    PrimeCheckPage(),
  ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
  
        body: Row(
          children: [
            // Side tabs
            Container(
              width: 150, // Adjust as needed
              color: Colors.white,
              child: ListView(
                children: [
                  _buildTabItem(Icons.info, 'About', 0),
                  _buildTabItem(Icons.wifi, 'WiFi', 1),
                  _buildTabItem(Icons.build, 'IP Address', 2),
                  _buildTabItem(Icons.check_circle, 'Prime Check', 3),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      
      bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu, wifiStatusNotifier:  wifiStatusNotifier, isStarted: false,),
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
        color: _selectedIndex == index ? Colors.teal.shade300 : Colors.transparent,
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
  





