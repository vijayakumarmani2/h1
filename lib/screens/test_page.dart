import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hba1c_analyzer_1/services/serial_port_service.dart';
import 'dart:async';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'dart:math' as math;

class TestPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  TestPage({required this.onBackToMenu});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> cards = [];

  final ScrollController _scrollController =
      ScrollController(); // ScrollController

  bool _isStarted = false;
  var running_status = "";

  int _adc_value1 = 1; // To track if the action has started
  int _adc_value2 = 1;
  var _absorbance_value = "0.0";

  void _addCard() {
    if (_isStarted || isCalSwitched)
      return; // Disable button if action has started

    if (cards.length < 10) {
      setState(() {
        cards.add({
          'sampleName': '',
          'type': '-',
          'result': '0.0',
        });
      });
      // Scroll to the bottom of the ListView
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      // Show a SnackBar if the maximum limit is reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum of 10 cards can be added.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addCals() {
    if (cards.isEmpty) {
      // Ensure room for at least two cards
      setState(() {
        cards.add({
          'sampleName': 'Calibrator 1',
          'type': 'D',
          'result': '5.5',
        });
        cards.add({
          'sampleName': 'Calibrator 2',
          'type': 'D',
          'result': '9.9',
        });
      });

      // Scroll to the bottom of the ListView
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      // Show a SnackBar if the maximum limit is reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Samples should be empty'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeAll() {
    if (_isStarted) return;

    if (cards.isNotEmpty) {
      setState(() {
        cards.clear();
      });
    }
  }

  void _removeLastCard() {
    if (_isStarted || isCalSwitched) return;

    if (cards.isNotEmpty) {
      setState(() {
        cards.removeLast();
      });
    }
  }

  bool isCalSwitched = false;
  bool isQcSwitched = false;

  bool isRunning = false;
  int runningTime = 120;
  Timer? timer;
  String _temp_val = "0";
  int secs = 0;
  late AnimationController _animationController;
  SerialReader? serialReader;
  String errorMessage = '';
  Queue<String> dataQueue = Queue();
  List<String> log = [];
  String buffer = '';

  @override
  void initState() {
    super.initState();
    initializeSerialReader();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duration of the ripple animation
    )..repeat(); // Repeat the ripple animation
  }

  void initializeSerialReader() {
    serialReader = SerialReader('/dev/ttyUSB0');
    // serialReader = SerialReader('COM5');
    if (!serialReader!.init()) {
      print(
          'Failed to open serial port /dev/ttyUSB0. Please check the connection.');
      // Show a SnackBar if the maximum limit is reached

      print('Failed to open serial port. Please check the connection.');
    } else {
      serialReader!.getStream()!.listen((data) {
        // Append received data to the buffer
        buffer += String.fromCharCodes(data);

        // Extract data between `<` and `>` and add to the queue
        while (buffer.contains('<') && buffer.contains('>')) {
          final start = buffer.indexOf('<');
          final end = buffer.indexOf('>', start);
          if (end > start) {
            dataQueue.add(buffer.substring(start + 1, end));
            buffer = buffer.substring(end + 1);
          } else {
            break;
          }
        }

        // Process data from the queue
        while (dataQueue.isNotEmpty) {
          processData(dataQueue.removeFirst());
        }
      }, onError: (error) {
        print('Error reading serial port: $error');
      }, onDone: () {
        print('Serial port communication ended unexpectedly.');
      });
    }
  }

  void processData(String data) {
    if (isTemperatureData(data)) {
      log.add('Temperature data: $data');
      _temp_val = data;
      print('Temperature data processed: $_temp_val');
    } else if (isAbsorbanceData1(data)) {
      log.add('Absorbance1 data: $data');

      _adc_value1 = int.parse(data.substring(1, data.length));

      print('Absorbance1 data processed: $data');
    } else if (isAbsorbanceData2(data)) {
      log.add('Absorbance2 data: $data');
      _adc_value2 = int.parse(data.substring(1, data.length));
      print('Absorbance2 data processed: $data');
    } else {
      log.add('Unknown data format: $data');
      print('Unknown data format received: $data');
    }
  }

  double calculateAbsorbance(int intensity, int referenceIntensity) {
    if (intensity <= 0 || referenceIntensity <= 0) {
      throw ArgumentError('Intensity values must be greater than 0');
    }
    return math.log(referenceIntensity / intensity) / math.log(10);
  }

  bool isTemperatureData(String data) {
    // Example logic for temperature data
    return data.startsWith('T') || data.length < 5;
  }

  bool isAbsorbanceData1(String data) {
    // Example logic for absorbance data
    return data.startsWith('A') || data.length >= 8;
  }

  bool isAbsorbanceData2(String data) {
    // Example logic for absorbance data
    return data.startsWith('B') || data.length >= 8;
  }

  List<FlSpot> spots = [];

  void addFlSpot(double x, double y) {
    setState(() {
      spots.add(FlSpot(x, y));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (cards.isEmpty) {
      // Show error if no cards are added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one sample before starting.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    for (var card in cards) {
      if (card['sampleName'].isEmpty || card['type'] == '-') {
        // Show error if any card has invalid data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Ensure all cards have a valid Sample Name and Type.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // If all validations pass, start the action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action started successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      isRunning = true;
      runningTime = 120;
      running_status = "Running";
      _isStarted = true; // Disable Add and Remove buttons
    });
    _animationController.repeat();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        runningTime--;
        _absorbance_value =
            calculateAbsorbance(_adc_value2, _adc_value1).toStringAsFixed(4);
        secs++;
        print('_absorbance_value : $secs - $_absorbance_value');
        addFlSpot(secs.toDouble(), double.parse(_absorbance_value));
        if (runningTime == 0) {
          secs = 0;
          running_status = "Tested";
          _isStarted = false;
          timer.cancel(); // Disable Add and Remove buttons
        }
      });
    });
    // Perform the intended action here
    print('Action performed!');
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
      _isStarted = false;
      running_status = "Tested";
      secs = 0;
      spots = []; // Clear the data points
    });
    timer?.cancel();
  }

  TextEditingController _textController = TextEditingController();
  String _text = ''; // To store the current text

  void _showCustomKeyboard(BuildContext context, int index) {
    _textController.text = cards[index]['sampleName']; // Set initial value
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // TextField on top of the keyboard
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type here...',
                ),
              ),
              const SizedBox(height: 20),
              // Virtual Keyboard
              Expanded(
                child: VirtualKeyboard(
                  type: VirtualKeyboardType.Alphanumeric,
                  postKeyPress: (key) {
                    // Handle key press and update the specific card's sampleName
                    if (key.keyType == VirtualKeyboardKeyType.String) {
                      setState(() {
                        cards[index]['sampleName'] += key.text!;
                        _textController.text = cards[index]['sampleName'];
                        _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length));
                      });
                    } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                        key.action == VirtualKeyboardKeyAction.Backspace) {
                      setState(() {
                        if (cards[index]['sampleName'].isNotEmpty) {
                          cards[index]['sampleName'] =
                              cards[index]['sampleName'].substring(
                                  0, cards[index]['sampleName'].length - 1);
                          _textController.text = cards[index]['sampleName'];
                          _textController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _textController.text.length));
                        }
                      });
                    } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                        key.action == VirtualKeyboardKeyAction.Return) {
                      // Close the keyboard
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleType(int index) {
    setState(() {
      if (cards[index]['type'] == '-') {
        cards[index]['type'] = 'W';
      } else if (cards[index]['type'] == 'W') {
        cards[index]['type'] = 'D';
      } else if (cards[index]['type'] == 'D') {
        cards[index]['type'] = '-';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel: Table and Column/Filter Data
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Sample Table
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color.fromARGB(0, 91, 87, 87)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: 520,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Header Row
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 0, 150,
                                    135), // Light blue header background
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners for the header
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'S No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 254, 254,
                                            254), // Dark text color
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      'Sample Name',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 254, 254, 254),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Type',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 254, 254, 254),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Result',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 254, 254, 254),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(thickness: 1.0), // Divider below the header
                            // List of Cards
                            Expanded(
                              child: cards.isEmpty
                                  ? Container(
                                      child: Center(
                                        child: Text(
                                          'Add sample here', // Message when no cards are present
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(255, 0, 112, 110),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      color: Color.fromARGB(30, 0, 112, 110),
                                      width: 500,
                                    )
                                  : ListView.builder(
                                      controller:
                                          _scrollController, // Attach ScrollController
                                      itemCount: cards.length,
                                      itemBuilder: (context, index) {
                                        final card = cards[index];
                                        return Card(
                                          elevation:
                                              0, // Increased elevation for a subtle shadow effect
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded corners
                                          ),
                                          // Added horizontal margin
                                          color: Color.fromARGB(0, 101, 96,
                                              96), // Background color
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 1.0,
                                                horizontal:
                                                    8.0), // Consistent padding
                                            child: Row(
                                              children: [
                                                // Serial Number
                                                Expanded(
                                                  flex: 1,
                                                  child: ClipPath(
                                                    clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          12), // Increased padding for better spacing
                                                      decoration: const BoxDecoration(
                                                          border: Border(
                                                                  bottom: BorderSide(
                                                                    color: Color.fromARGB(124, 0, 112, 110),
                                                                    width: 3.0,
                                                                    style: BorderStyle.solid,
                                                                  ),
                                                                ),
                                                        color: Color.fromARGB(30, 0, 112, 110),
                                                        // Rounded corners for inner boxes
                                                      ),
                                                      child: Text(
                                                        '${index + 1}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 18,
                                                          color: Color.fromARGB(255, 0, 112, 110), // Darker text color
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Sample Name
                                                Expanded(
                                                  flex: 4,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        _showCustomKeyboard(
                                                            context, index),
                                                    child: ClipPath(
                                                      clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                         border: Border(
                                                                  bottom: BorderSide(
                                                                    color: Color.fromARGB(124, 0, 112, 110),
                                                                    width: 3.0,
                                                                    style: BorderStyle.solid,
                                                                  ),
                                                                ),
                                                        color: Color.fromARGB(30, 0, 112, 110),
                                                         
                                                        ),
                                                        child: Text(
                                                          cards[index][
                                                              'sampleName'], // Display card-specific sampleName
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color.fromARGB(255, 0, 112, 110),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Type
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        _toggleType(index),
                                                    child: ClipPath(
                                                      clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                                  bottom: BorderSide(
                                                                    color: Color.fromARGB(124, 0, 112, 110),
                                                                    width: 3.0,
                                                                    style: BorderStyle.solid,
                                                                  ),
                                                                ),
                                                        color: Color.fromARGB(30, 0, 112, 110),
                                                         
                                                        ),
                                                        child: Text(
                                                          card['type'],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color.fromARGB(255, 0, 112, 110),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Result
                                                Expanded(
                                                  flex: 3,
                                                  child: ClipPath(
                                                    clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
                                                    child: Container(
                                                      padding: EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                                  bottom: BorderSide(
                                                                    color: Color.fromARGB(124, 0, 112, 110),
                                                                    width: 3.0,
                                                                    style: BorderStyle.solid,
                                                                  ),
                                                                ),
                                                        color: Color.fromARGB(30, 0, 112, 110),
                                                       
                                                      ),
                                                      child: Text(
                                                        card['result'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color.fromARGB(255, 0, 112, 110),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            Divider(thickness: 1.0),
                            // Add and Remove Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _addCard,
                                  child: Icon(Icons.add_circle_rounded,
                                      color: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      size: 24),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff2196F3),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _removeLastCard,
                                  child: Icon(Icons.delete,
                                      color: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      size: 24),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffF44336),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // A B L ,Column and Filter Data
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        // A B L
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 90.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.7,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation(
                                            Color.fromARGB(159, 100, 183, 251)),
                                        borderRadius: 12.0,borderColor: Color.fromARGB(30, 0, 60, 112),borderWidth: 3,
                                        center: Text(
                                          "Eluent\n    A",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "698/800 ml",
                                    style: TextStyle(
                                      color: Color.fromARGB(208, 15, 59, 94),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 90.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.8,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation(
                                            Color.fromARGB(159, 100, 183, 251)),
                                        borderRadius: 12.0,borderColor: Color.fromARGB(30, 0, 60, 112),borderWidth: 3,
                                        center: Text(
                                          "Eluent\n    B",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "334/400 ml",
                                    style: TextStyle(
                                      color: Color.fromARGB(208, 15, 59, 94),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 90.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.8696,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                Color.fromARGB(159, 100, 183, 251)),
                                        borderRadius: 12.0,borderColor: Color.fromARGB(30, 0, 60, 112),borderWidth: 3,
                                        center: const Text(
                                          "H/W",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "2174/2500 ml",
                                    style: TextStyle(
                                      color: Color.fromARGB(208, 15, 59, 94),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                        // Column and Filter
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 180,
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: LiquidLinearProgressIndicator(
                                          direction: Axis.horizontal,
                                          value: 0.85,
                                          backgroundColor: Colors.white,
                                          valueColor: AlwaysStoppedAnimation(
                                              Color.fromARGB(124, 0, 112, 110)),
                                        borderRadius: 12.0,borderColor: Color.fromARGB(30, 0, 112, 110),borderWidth: 3,
                                          center: Text(
                                            "Column",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  195, 12, 78, 31),
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "1186/1200 ml",
                                      style: TextStyle(
                                        color: Color.fromARGB(195, 12, 78, 31),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 180,
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: LiquidLinearProgressIndicator(
                                          direction: Axis.horizontal,
                                          value: 0.9,
                                          backgroundColor: Colors.white,
                                          valueColor: AlwaysStoppedAnimation(
                                              Color.fromARGB(124, 0, 112, 110)),
                                        borderRadius: 12.0,borderColor: Color.fromARGB(30, 0, 112, 110),borderWidth: 3,
                                          center: Text(
                                            "Filter",
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  195, 12, 78, 31),
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "386/400 ml",
                                      style: TextStyle(
                                        color: Color.fromARGB(195, 12, 78, 31),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right Panel: Graph and Information
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Graph Section with Line Chart
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0, 158, 158, 158)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 130,
                          minY: 0.0,
                          maxY: 1.8,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameWidget: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "Abs. Value",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 1, 90, 77),
                                  ),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 0.2,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Text(
                                  "Time",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 1, 86, 75),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 0.2,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Color.fromARGB(255, 6, 138, 121)
                                    .withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Color.fromARGB(255, 6, 138, 121)
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          backgroundColor: const Color(
                              0xFFF5F5F5), // Background color for the chart
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [
                                  // Gradient start color
                                  Colors.teal,
                                  Colors.teal, // Gradient end color
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: const LinearGradient(
                                  colors: [
                                    // Hex code #224c84
                                    Color.fromARGB(71, 14, 122, 61),
                                    Color.fromARGB(63, 34, 77,
                                        132), // Gradient end (faded)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: false,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    strokeWidth: 2,
                                    strokeColor:
                                        Color.fromARGB(159, 0, 136, 122),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Information Section
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(0, 158, 158, 158)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pressure
                                    Row(
                                      children: [
                                        Icon(Icons.speed,
                                            color: Colors.orange, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          '0 MPa',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Type
                                    Row(
                                      children: [
                                        Icon(Icons.category,
                                            color: Colors.red, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Dil. Blood',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Temperature
                                    Row(
                                      children: [
                                        Icon(Icons.thermostat,
                                            color: Colors.blue, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          '$_temp_val \u00B0C',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Calibration
                                    Row(
                                      children: [
                                        Icon(Icons.straighten,
                                            color: Colors.green, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Y=1.000X+0.000',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: 40),
                                Container(
                                  child: // Absorbance
                                      Container(
                                    height: 70,
                                    child: Column(
                                      children: [
                                        Icon(Icons.opacity,
                                            color: Colors.purple, size: 32),
                                        SizedBox(height: 8),
                                        Text(
                                          '${_absorbance_value}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
// Buttons Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Cal Button with Switch
                              Column(
                                children: [
                                  const Text('CAL',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Switch(
                                    value: isCalSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        isCalSwitched = value;
                                        if (isCalSwitched) {
                                          _addCals();
                                        } else {
                                          _removeAll();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              // QC Button with Switch
                              Column(
                                children: [
                                  const Text('QC',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Switch(
                                    value: isQcSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        isQcSwitched = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              // Ripple Animation and Timer
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Ripple Animation
                                      AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              for (double scale in [
                                                0.3,
                                                0.6,
                                                0.9
                                              ])
                                                Transform.scale(
                                                  scale: _animationController
                                                              .value *
                                                          scale +
                                                      1.0,
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.teal
                                                          .withOpacity((1.0 -
                                                                  _animationController
                                                                      .value) *
                                                              0.5),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                      // Center Content
                                      isRunning
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  running_status,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  '$runningTime s',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: stopTimer,
                                                  child: const Text(
                                                    'Stop',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : ElevatedButton(
                                              onPressed: startTimer,
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                backgroundColor: Colors.teal,
                                                padding:
                                                    const EdgeInsets.all(20),
                                              ),
                                              child: const Text(
                                                'Start',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onBackToMenu,
        child: Icon(
          Icons.home,
          size: 35,
        ),
        backgroundColor: Color(0xFF00706e),
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Path _buildHeartPath() {
    double scale = 0.909; // Scaling factor to fit 100x100
    return Path()
      ..moveTo(55 * scale, 15 * scale)
      ..cubicTo(55 * scale, 12 * scale, 50 * scale, 0, 30 * scale, 0)
      ..cubicTo(0, 0, 0, 37.5 * scale, 0, 37.5 * scale)
      ..cubicTo(0, 55 * scale, 20 * scale, 77 * scale, 55 * scale, 95 * scale)
      ..cubicTo(90 * scale, 77 * scale, 110 * scale, 55 * scale, 110 * scale,
          37.5 * scale)
      ..cubicTo(110 * scale, 37.5 * scale, 110 * scale, 0, 80 * scale, 0)
      ..cubicTo(65 * scale, 0, 55 * scale, 12 * scale, 55 * scale, 15 * scale)
      ..close();
  }

  Path _buildBottlePath() {
    return Path()
      // Handle
      ..moveTo(45, 10) // Start of the handle
      ..lineTo(55, 5) // Top-left of the handle
      ..arcToPoint(
        Offset(75, 5), // Top-right of the handle
        radius: Radius.circular(15),
        clockwise: false,
      )
      ..lineTo(85, 10) // End of the handle

      // Cap
      ..lineTo(75, 20) // Right side of the cap
      ..lineTo(45, 20) // Left side of the cap
      ..close()

      // Body
      ..moveTo(30, 20) // Left of the bottle body
      ..lineTo(30, 70) // Bottom-left of the bottle
      ..arcToPoint(
        Offset(70, 70), // Bottom-right curve of the bottle
        radius: Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(70, 20) // Top-right of the bottle
      ..arcToPoint(
        Offset(30, 20), // Top-left curve
        radius: Radius.circular(20),
        clockwise: false,
      )
      ..close()

      // Base
      ..moveTo(30, 70) // Left bottom of the bottle
      ..arcToPoint(
        Offset(70, 70), // Right bottom curve
        radius: Radius.circular(15),
        clockwise: true,
      )
      ..close();
  }

  Widget buildStatusCard(
    String title,
    String mainValue,
    String subTitle,
    String bottomValue,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 158, 158, 158)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(mainValue, style: const TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(bottomValue),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedLiquidLinearProgressIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _AnimatedLiquidLinearProgressIndicatorState();
}

class _AnimatedLiquidLinearProgressIndicatorState
    extends State<_AnimatedLiquidLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _animationController.value * 100;

    return Center(
      child: Container(
        width: 100,
        height: 75.0,
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: LiquidLinearProgressIndicator(
          value: _animationController.value,
          direction: Axis.vertical,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
          borderRadius: 12.0,
          center: Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
