import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> cards = [];

  final ScrollController _scrollController =
      ScrollController(); // ScrollController

  void _addCard() {
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

  void _removeLastCard() {
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

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duration of the ripple animation
    )..repeat(); // Repeat the ripple animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      isRunning = true;
      runningTime = 120;
    });
    _animationController.repeat();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        runningTime--;
      });
    });
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
  }

  TextEditingController _textController = TextEditingController();
  String _text = ''; // To store the current text

  void _showCustomKeyboard(BuildContext context) {
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
                    // Handle key press and update TextField
                    if (key.keyType == VirtualKeyboardKeyType.String) {
                      // Append only valid character keys
                      setState(() {
                        _text += key.text!;
                        _textController.text = _text;
                        _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length));
                      });
                    } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                        key.action == VirtualKeyboardKeyAction.Backspace) {
                      // Handle backspace
                      setState(() {
                        if (_text.isNotEmpty) {
                          _text = _text.substring(0, _text.length - 1);
                          _textController.text = _text;
                          _textController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _textController.text.length));
                        }
                      });
                    } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                        key.action == VirtualKeyboardKeyAction.Return) {
                      // Handle the Enter key
                      setState(() {
                        _textController.text = _text;
                      });
                      Navigator.pop(context); // Close the keyboard
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
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color.fromARGB(0, 91, 87, 87)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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
                                color: Color.fromARGB(255, 213, 225,
                                    255), // Light blue header background
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners for the header
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'S No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(
                                            255, 33, 49, 89), // Dark text color
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Sample Name',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 33, 49, 89),
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
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 33, 49, 89),
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
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 33, 49, 89),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(thickness: 1.0), // Divider below the header
                            // List of Cards
                            Expanded(
                              child: ListView.builder(
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
                                    color: Color.fromARGB(
                                        0, 101, 96, 96), // Background color
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
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  12), // Increased padding for better spacing
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color.fromARGB(
                                                        60, 18, 44, 138)),
                                                color: Color.fromARGB(
                                                    255, 245, 245, 245),
                                                borderRadius: BorderRadius.circular(
                                                    5), // Rounded corners for inner boxes
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255,
                                                      33,
                                                      49,
                                                      89), // Darker text color
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Sample Name
                                          Expanded(
                                            flex: 4,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _showCustomKeyboard(context),
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          60, 18, 44, 138)),
                                                  color: Color.fromARGB(
                                                      255, 245, 245, 245),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  _text,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 33, 49, 89),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Type
                                          Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                              onTap: () => _toggleType(index),
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          60, 18, 44, 138)),
                                                  color: Color.fromARGB(
                                                      255, 245, 245, 245),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  card['type'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 33, 49, 89),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Result
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color.fromARGB(
                                                        60, 18, 44, 138)),
                                                color: Color.fromARGB(
                                                    255, 245, 245, 245),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                card['result'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 33, 49, 89),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _addCard,
                                  child: Text('Add'),
                                ),
                                ElevatedButton(
                                  onPressed: _removeLastCard,
                                  child: Text('Remove'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
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
                // Column and Filter Data
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 75.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.7,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation(
                                            const Color.fromARGB(
                                                255, 100, 183, 251)),
                                        borderRadius: 12.0,
                                        center: Text(
                                          "A",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "698/800 ml",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12.0,
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
                                      height: 75.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.8,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation(
                                            const Color.fromARGB(
                                                255, 100, 183, 251)),
                                        borderRadius: 12.0,
                                        center: Text(
                                          "B",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "334/400 ml",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12.0,
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
                                      height: 75.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: LiquidLinearProgressIndicator(
                                        value: 0.8696,
                                        direction: Axis.vertical,
                                        backgroundColor: Colors.white,
                                        valueColor: AlwaysStoppedAnimation(
                                            const Color.fromARGB(
                                                255, 100, 183, 251)),
                                        borderRadius: 12.0,
                                        center: Text(
                                          "L",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(208, 15, 59, 94),
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "2174/2500 ml",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 200,
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: LiquidLinearProgressIndicator(
                                          direction: Axis.horizontal,
                                          value: 0.85,
                                          backgroundColor: Colors.white,
                                          valueColor: AlwaysStoppedAnimation(
                                              Color.fromARGB(
                                                  255, 76, 222, 134)),
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
                                        fontSize: 12.0,
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
                                        width: 200,
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: LiquidLinearProgressIndicator(
                                          direction: Axis.horizontal,
                                          value: 0.9,
                                          backgroundColor: Colors.white,
                                          valueColor: AlwaysStoppedAnimation(
                                              Color.fromARGB(
                                                  255, 76, 222, 134)),
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
                                        fontSize: 12.0,
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
                                    color: Colors.black,
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
                                      color: Colors.grey,
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
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          backgroundColor: const Color(
                              0xFFF5F5F5), // Background color for the chart
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 0.0),
                                const FlSpot(10, 0.8),
                                const FlSpot(18, 1.0),
                                const FlSpot(28, 0.78),
                                const FlSpot(35, 1.5),
                                const FlSpot(50, 1.6),
                                const FlSpot(70, 0.2),
                                const FlSpot(85, 0.4),
                                const FlSpot(95, 0.25),
                                const FlSpot(120, 0.25),
                              ],
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4A90E2), // Gradient start color
                                  Color(0xFF007AFF), // Gradient end color
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
                                    Color.fromARGB(
                                        91, 34, 77, 132), // Hex code #224c84
                                    Color.fromARGB(71, 14, 122,
                                        61), // Gradient end (faded)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF4A90E2),
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
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Absorbance
                                    Row(
                                      children: [
                                        Icon(Icons.opacity,
                                            color: Colors.purple, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          '0.0022',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Pressure
                                    Row(
                                      children: [
                                        Icon(Icons.speed,
                                            color: Colors.orange, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          '7.6MPa',
                                          style: TextStyle(
                                            fontSize: 16,
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
                                          'D.B.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 60),
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
                                          '38.9°C',
                                          style: TextStyle(
                                            fontSize: 16,
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
                                          'Y=1.073X+0.434',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Color.fromARGB(255, 76, 76, 76),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                  const Text('Cal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Switch(
                                    value: isCalSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        isCalSwitched = value;
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
                                                      color: Colors.blue
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
                                                const Text(
                                                  'Running',
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
                                                  child: const Text('Stop'),
                                                ),
                                              ],
                                            )
                                          : ElevatedButton(
                                              onPressed: startTimer,
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(20),
                                              ),
                                              child: const Text('Start'),
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