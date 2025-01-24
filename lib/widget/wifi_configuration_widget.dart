import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/linux_wif_manager.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';


class WiFiConfigurationWidget extends StatefulWidget {
  final ValueNotifier<bool> wifiStatusNotifier;

  WiFiConfigurationWidget({required this.wifiStatusNotifier});
  @override
  _WiFiConfigurationWidgetState createState() => _WiFiConfigurationWidgetState();
}

class _WiFiConfigurationWidgetState extends State<WiFiConfigurationWidget> {
  List<String> networks = [];
  String? activeNetwork; // Tracks the currently active connected network
  String password = "";

  @override
  void initState() {
    super.initState();
    fetchNetworks();
  }

  Future<void> fetchNetworks() async {
    try {
      // Fetch available networks and active network
      List<String> availableNetworks = await LinuxWiFiManager.getAvailableNetworks();
      String? active = await LinuxWiFiManager.getActiveNetwork();
      setState(() {
        networks = availableNetworks;
        activeNetwork = active;
      });
      if(activeNetwork != null){
        // Update the WiFi status notifier
      widget.wifiStatusNotifier.value = true;
      }
    } catch (e) {
       widget.wifiStatusNotifier.value = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to fetch networks: $e"),
      ));
    }
  }

  void connectToNetwork(String ssid) async {
    try {
      bool success = await LinuxWiFiManager.connectToNetwork(ssid, password);
      if (success) {
        setState(() {
          activeNetwork = ssid; // Update active network
        });
         widget.wifiStatusNotifier.value = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Connected to $ssid"),
        ));
      } else {
         widget.wifiStatusNotifier.value = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to connect to $ssid"),
        ));
      }
    } catch (e) {
       widget.wifiStatusNotifier.value = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error connecting to network: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text("WiFi Configuration"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchNetworks, // Refresh network list and active network
            ),
          ],
        ),
        Expanded(
          child: networks.isEmpty
              ? Center(child: CircularProgressIndicator()) // Show loader if no networks available
              : ListView.builder(
                  itemCount: networks.length,
                  itemBuilder: (context, index) {
                    String network = networks[index];
                    bool isActive = activeNetwork == network; // Check if this is the active network

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: isActive ? Colors.teal[100] : null, // Highlight active network
                      child: ListTile(
                        title: Text(
                          network,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.teal : Colors.black,
                          ),
                        ),
                        trailing: isActive
                            ? Icon(Icons.wifi, color: Colors.teal) // Icon for active network
                            : ElevatedButton(
                                onPressed: () {
                                  showPasswordDialog(network); // Show password dialog
                                },
                                child: Text("Connect"),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void showPasswordDialog(String network) {
    String tempPassword = "";
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Connect to $network"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Password Input and Toggle Visibility
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          obscureText: !isPasswordVisible, // Toggle visibility
                          readOnly: true, // Prevent native keyboard
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: tempPassword),
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        children: [
                          Text("Show"),
                          Switch(
                            value: isPasswordVisible,
                            onChanged: (value) {
                              setState(() {
                                isPasswordVisible = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Virtual Keyboard
                  VirtualKeyboard(
                    height: 300,
                    type: VirtualKeyboardType.Alphanumeric,
                    postKeyPress: (key) {
                      setState(() {
                        if (key.text != null) {
                          tempPassword += key.text!;
                        } else if (key.action == VirtualKeyboardKeyAction.Backspace &&
                            tempPassword.isNotEmpty) {
                          tempPassword = tempPassword.substring(0, tempPassword.length - 1);
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    password = tempPassword;
                    connectToNetwork(network);
                  },
                  child: Text("Connect"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
