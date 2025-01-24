import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
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
    // await DatabaseHelper.instance.insertLatestDBCal();
    print(await DatabaseHelper.instance.fetchLatestDBCal());
    try {
      active = await LinuxWiFiManager.getActiveNetwork();
      setState(() {
        // Update the WiFi status notifier based on the active network
        if (active != null && active!.contains("wlan")) {
          wifiStatusNotifier.value = true;
        } else {
          wifiStatusNotifier.value = false;
        }
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
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future: DatabaseHelper.instance.fetchCalibrationInfo(),
                        builder: (context, snapshot) {
                          // Provide default values when no data is available
                          final data = snapshot.data ??
                              {
                                'date': '',
                                'lot_no': '',
                                'k_value': '',
                                'b_value': '',
                              };

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print("Error fetching data: ${snapshot.error}");
                          }

                          return Column(
                            children: [
                              Text(
                                'Latest Calibration Info',
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
                                      color:
                                          const Color.fromARGB(0, 0, 150, 135),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                          InfoRowValue(value: data['date']),
                                          InfoRowValue(value: data['lot_no']),
                                          InfoRowValue(
                                              value:
                                                  data['k_value'].toString()),
                                          InfoRowValue(
                                              value:
                                                  data['b_value'].toString()),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future:
                            DatabaseHelper.instance.fetchLastCalibrationInfo(),
                        builder: (context, snapshot) {
                          // Provide default values when no data is available
                          final data = snapshot.data ??
                              {
                                'date': '',
                                'lot_no': '',
                                'k_value': '',
                                'b_value': '',
                              };

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print("Error fetching data: ${snapshot.error}");
                          }

                          return Column(
                            children: [
                              Text(
                                'Last Calibration Info',
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
                                      color:
                                          const Color.fromARGB(0, 0, 150, 135),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                          InfoRowValue(value: data['date']),
                                          InfoRowValue(value: data['lot_no']),
                                          InfoRowValue(
                                              value:
                                                  data['k_value'].toString()),
                                          InfoRowValue(
                                              value:
                                                  data['b_value'].toString()),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future: DatabaseHelper.instance.fetchLatestDBCal(),
                        builder: (context, snapshot) {
                          // Provide default values when no data is available
                          final data = snapshot.data ??
                              {
                                'lot_no': '123456',
                                'low_value': '0',
                                'high_value': '0',
                                'low_cal_pos': '1',
                                'high_cal_pos': '2',
                              };

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print("Error fetching data: ${snapshot.error}");
                          }

                          return Column(
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
                                      color:
                                          const Color.fromARGB(0, 0, 150, 135),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                            initialValue: data['lot_no'],
                                            onSave: (newValue) async {
                                              await DatabaseHelper.instance
                                                  .updateDBCalLotNo(
                                                      1, newValue);
                                              print(
                                                  "Updated Lot No. Value: $newValue");
                                              // Add logic to save the new value
                                            },
                                          ),
                                          EditableInfoValueWithNumericKeyboard(
                                            initialValue:
                                                data['low_value'].toString(),
                                            onSave: (newValue) async {
                                              await DatabaseHelper.instance
                                                  .updateDBCalLowValue(
                                                      1, newValue);
                                              print(
                                                  "Updated Low Value: $newValue");
                                              // Add logic to save the new value
                                            },
                                          ),
                                          EditableInfoValueWithNumericKeyboard(
                                            initialValue:
                                                data['high_value'].toString(),
                                            onSave: (newValue) {
                                              DatabaseHelper.instance
                                                  .updateDBCalHighValue(
                                                      1, newValue);
                                              print(
                                                  "Updated High Value: $newValue");
                                              // Add logic to save the new value
                                            },
                                          ),
                                          InfoRowValue(
                                              value: data['low_cal_pos']
                                                  .toString()),
                                          InfoRowValue(
                                              value: data['high_cal_pos']
                                                  .toString()),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                Container(
                  height: 140,
                  width: 400,
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: DatabaseHelper.instance.fetchManualData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      // Default data with '-'
                      final data = snapshot.data ??
                          {
                            'hba1c_k': '-',
                            'hba1c_b': '-',
                          };

                      final TextEditingController hba1cKController =
                          TextEditingController(
                        text: data['hba1c_k']?.toString() ?? '-',
                      );
                      final TextEditingController hba1cBController =
                          TextEditingController(
                        text: data['hba1c_b']?.toString() ?? '-',
                      );

                      return Column(
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
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(0, 0, 150, 135),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      InfoRowLabel(label: "HbA1c K"),
                                      InfoRowLabel(label: "HbA1c B"),
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
                                      EditableInfoValueWithNumericKeyboard(
                                        initialValue: hba1cKController.text,
                                        onSave: (newValue) async {
                                          final id = data['id'];
                                          if (data != null) {
                                            await DatabaseHelper.instance
                                                .updateManualData(id, {
                                              'hba1c_k': newValue == '-'
                                                  ? null
                                                  : double.tryParse(newValue),
                                            });
                                          } else {
                                            await DatabaseHelper.instance
                                                .insertManualData({
                                              'hba1c_k': newValue == '-'
                                                  ? null
                                                  : double.tryParse(newValue),
                                              'hba1c_b': hba1cBController
                                                          .text ==
                                                      '-'
                                                  ? null
                                                  : double.tryParse(
                                                      hba1cBController.text),
                                            });
                                          }
                                          print("Updated hba1c_k: $newValue");
                                        },
                                      ),
                                      EditableInfoValueWithNumericKeyboard(
                                        initialValue: hba1cBController.text,
                                        onSave: (newValue) async {
                                          final id = data['id'];
                                          if (data != null) {
                                            await DatabaseHelper.instance
                                                .updateManualData(id, {
                                              'hba1c_b': newValue == '-'
                                                  ? null
                                                  : double.tryParse(newValue),
                                            });
                                          } else {
                                            await DatabaseHelper.instance
                                                .insertManualData({
                                              'hba1c_k': hba1cKController
                                                          .text ==
                                                      '-'
                                                  ? null
                                                  : double.tryParse(
                                                      hba1cKController.text),
                                              'hba1c_b': newValue == '-'
                                                  ? null
                                                  : double.tryParse(newValue),
                                            });
                                          }
                                          print("Updated hba1c_b: $newValue");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedBottomNavigationBar(
        onBackToMenu: widget.onBackToMenu,
        wifiStatusNotifier: wifiStatusNotifier,
      ),
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
                }, style: ButtonStyle(  backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),),
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
