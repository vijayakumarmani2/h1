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
                        cards[index]['sampleName'] = cards[index]['sampleName']
                            .substring(0, cards[index]['sampleName'].length - 1);
                        _textController.text = cards[index]['sampleName'];
                        _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length));
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
          // Left Panel: Table 
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
    onTap: () => _showCustomKeyboard(context, index),
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(60, 18, 44, 138)),
        color: Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        cards[index]['sampleName'], // Display card-specific sampleName
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 33, 49, 89),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(161, 54, 165, 244),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _removeLastCard,
                                  child: Text('Remove'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(163, 244, 67, 54),
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
               
                ],
            ),
          ),
         ],
      ),
    );
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
