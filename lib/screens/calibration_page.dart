import 'package:flutter/material.dart';

class CalibrationPage extends StatelessWidget {
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
                              border: Border.all(color: const Color.fromARGB(0, 0, 150, 135), width: 1.5),
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
                                VerticalDivider(color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoRowValue(value: "2024/11/28 14:23:40"),
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
                              border: Border.all(color: const Color.fromARGB(0, 0, 150, 135), width: 1.5),
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
                                VerticalDivider(color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoRowValue(value: "2024/08/26 09:43:05"),
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
                              border: Border.all(color: const Color.fromARGB(0, 0, 150, 135), width: 1.5),
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
                                VerticalDivider(color: Colors.teal, thickness: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoRowValue(value: "GSX1240020"),
                                      InfoRowValue(value: "5.50"),
                                      InfoRowValue(value: "9.90"),
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
                  height: 157,width: 400,
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
                              border: Border.all(color: const Color.fromARGB(0, 0, 150, 135), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                const Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                     Text( "HbA1c K"),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      width: 190,height: 30,
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
                                     Text( "HbA1c B"),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      width: 190,height: 30,
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
