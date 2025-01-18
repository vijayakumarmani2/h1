import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';

class SystemPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  SystemPage({required this.onBackToMenu});

  _SystemPageState createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Main Content Area',
            style: TextStyle(fontSize: 20),
          ),
        ),
        bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu),
      ),
    );
  }
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