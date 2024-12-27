import 'package:flutter/material.dart';

class SystemPage extends StatelessWidget {
  final VoidCallback onBackToMenu;

  SystemPage({required this.onBackToMenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "System Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onBackToMenu,
        label: Text("Back to Menu"),
        icon: Icon(Icons.arrow_back),
        backgroundColor: Color(0xFF00706e),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
