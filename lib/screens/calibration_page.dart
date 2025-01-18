import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/linux_wif_manager.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class CalibrationPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  CalibrationPage({required this.onBackToMenu});

  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
    final ValueNotifier<bool> wifiStatusNotifier = ValueNotifier(false);
     String? active = null;
    
  @override
void initState() {
  super.initState();
  checkActiveNetwork(); // Call the asynchronous logic
}

Future<void> checkActiveNetwork() async {
  try {
    active = await LinuxWiFiManager.getActiveNetwork();
    setState(() {
      // Update the WiFi status notifier based on the active network
      wifiStatusNotifier.value = active != null;
    });
  } catch (e) {
    setState(() {
      wifiStatusNotifier.value = false;
    });
    // Optionally, handle errors (e.g., show a snackbar or log)
    print("Error fetching active network: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Calibration Info',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 150, 135),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      InfoRowLabel(label: "Date"),
                                      InfoRowLabel(label: "Lot No."),
                                      InfoRowLabel(label: "K"),
                                      InfoRowLabel(label: "B"),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                    color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InfoRowValue(
                                          value: "2024/11/28 14:23:40"),
                                      InfoRowValue(value: "GSX1240020"),
                                      InfoRowValue(value: "1.0725"),
                                      InfoRowValue(value: "0.4338"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Last Time',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 150, 135),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      InfoRowLabel(label: "Date"),
                                      InfoRowLabel(label: "Lot No."),
                                      InfoRowLabel(label: "K"),
                                      InfoRowLabel(label: "B"),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                    color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InfoRowValue(
                                          value: "2024/08/26 09:43:05"),
                                      InfoRowValue(value: "GSX1230020"),
                                      InfoRowValue(value: "1.1517"),
                                      InfoRowValue(value: "0.0930"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'D.B. Cal.',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 150, 135),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      InfoRowLabel(label: "Lot No."),
                                      InfoRowLabel(label: "Low"),
                                      InfoRowLabel(label: "High"),
                                      InfoRowLabel(label: "Low Cal Pos."),
                                      InfoRowLabel(label: "High Cal Pos."),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                    color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      EditableInfoValueWithKeyboard(
                                        initialValue: "GSX1240020",
                                        onSave: (newValue) {
                                          print(
                                              "Updated Lot No. Value: $newValue");
                                          // Add logic to save the new value
                                        },
                                      ),
                                      EditableInfoValueWithNumericKeyboard(
                                        initialValue: "5.50",
                                        onSave: (newValue) {
                                          print("Updated Low Value: $newValue");
                                          // Add logic to save the new value
                                        },
                                      ),
                                      EditableInfoValueWithNumericKeyboard(
                                        initialValue: "9.90",
                                        onSave: (newValue) {
                                          print(
                                              "Updated High Value: $newValue");
                                          // Add logic to save the new value
                                        },
                                      ),
                                      InfoRowValue(value: "1"),
                                      InfoRowValue(value: "2"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                Container(
                  height: 157,
                  width: 400,
                  child: Column(
                    children: [
                      Text(
                        'Manual',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 125,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(0, 0, 150, 135),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("HbA1c K"),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 190,
                                  height: 30,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("HbA1c B"),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 190,
                                  height: 30,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                                child: Text("Save"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
           bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu, wifiStatusNotifier: wifiStatusNotifier,),
    );
  }
}

class InfoRowLabel extends StatelessWidget {
  final String label;

  InfoRowLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black54,
      ),
    );
  }
}

class InfoRowValue extends StatelessWidget {
  final String value;

  InfoRowValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}

class EditableInfoValueWithKeyboard extends StatefulWidget {
  final String initialValue;
  final Function(String) onSave;

  EditableInfoValueWithKeyboard(
      {required this.initialValue, required this.onSave});

  @override
  _EditableInfoValueWithKeyboardState createState() =>
      _EditableInfoValueWithKeyboardState();
}

class _EditableInfoValueWithKeyboardState
    extends State<EditableInfoValueWithKeyboard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _showVirtualKeyboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // TextField to show current text being edited
              TextField(
                controller: _controller,
                readOnly: true, // Prevent direct editing
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Edit value...',
                ),
              ),
              const SizedBox(height: 16),
              // Virtual Keyboard
              Expanded(
                child: VirtualKeyboard(
                  type: VirtualKeyboardType.Alphanumeric,
                  preKeyPress: (key) {
                    if (key.keyType == VirtualKeyboardKeyType.String) {
                      setState(() {
                        _controller.text += key.text!;
                      });
                    } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                        key.action == VirtualKeyboardKeyAction.Backspace) {
                      setState(() {
                        if (_controller.text.isNotEmpty) {
                          _controller.text = _controller.text
                              .substring(0, _controller.text.length - 1);
                        }
                      });
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(_controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
        _showVirtualKeyboard();
      },
      child: Text(
        _controller.text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class EditableInfoValueWithNumericKeyboard extends StatefulWidget {
  final String initialValue;
  final Function(String) onSave;

  EditableInfoValueWithNumericKeyboard(
      {required this.initialValue, required this.onSave});

  @override
  _EditableInfoValueWithNumericKeyboardState createState() =>
      _EditableInfoValueWithNumericKeyboardState();
}

class _EditableInfoValueWithNumericKeyboardState
    extends State<EditableInfoValueWithNumericKeyboard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _showVirtualKeyboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // TextField to show current text being edited
              TextField(
                controller: _controller,
                readOnly: true, // Prevent direct editing
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter value...',
                ),
              ),
              const SizedBox(height: 16),
              // Virtual Keyboard
              Expanded(
                child: VirtualKeyboard(
                  type: VirtualKeyboardType.Numeric, // Restrict to numeric
                  preKeyPress: (key) {
                    setState(() {
                      if (key.keyType == VirtualKeyboardKeyType.String) {
                        _controller.text += key.text!;
                      } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                          key.action == VirtualKeyboardKeyAction.Backspace) {
                        if (_controller.text.isNotEmpty) {
                          _controller.text = _controller.text
                              .substring(0, _controller.text.length - 1);
                        }
                      }
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(_controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVirtualKeyboard(),
      child: Text(
        _controller.text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
