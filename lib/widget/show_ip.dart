import 'dart:io';
import 'package:flutter/material.dart';


class IPDisplayScreen extends StatefulWidget {
  @override
  _IPDisplayScreenState createState() => _IPDisplayScreenState();
}

class _IPDisplayScreenState extends State<IPDisplayScreen> {
  String? ipAddress;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIPAddress();
  }

  Future<void> fetchIPAddress() async {
    try {
      final result = await Process.run('hostname', ['-I']);
      setState(() {
        ipAddress = result.stdout.toString().trim();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        ipAddress = "Error: Unable to fetch IP address";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IP Address"),
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.teal.shade300, Colors.teal.shade700],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(
                color: Colors.white,
              )
            else
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.network_wifi,
                        size: 60,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Your System's Pi IP Address:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ipAddress ?? "No IP Address Found",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchIPAddress();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh IP Address"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
