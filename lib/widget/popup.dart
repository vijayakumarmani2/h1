import 'package:flutter/material.dart';

/// Common popup widget with "OK" button
class CommonPopup {
  static void show(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onOk,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onOk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
