import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui; // Import 'dart:ui' for rendering

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
import 'package:image/image.dart' as img;

class ResultPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  ResultPage({required this.onBackToMenu});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isSearchExpanded = false;
  String searchText = "";
  String filterColumn = "ID";

  final ScrollController _verticalScrollController = ScrollController();

  List<Map<String, dynamic>> data = []; // List to hold the fetched data
  List<int> selectedRows = [];

  List<FlSpot> spots = [
    FlSpot(0, 1),
    FlSpot(10, 1.5),
    FlSpot(20, 1.2),
    FlSpot(30, 0.8),
    FlSpot(40, 1.0),
  ]; // List of selected row IDs

  void logEvent(String type, String message, {required String page}) async {
    await DatabaseHelper.instance.logEvent(type, message, page: page);
    print("$type: $message");
  }

  @override
  void initState() {
    super.initState();
    _fetchResults(); // Fetch data from DB
  }

  // Fetch results from the database
  Future<void> _fetchResults() async {
    final results =
        await DatabaseHelper.instance.fetchResults(); // Fetch all rows
    setState(() {
      data = results; // Assign fetched data to the list
    });
  }

  // Show confirmation dialog
  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  Future<Map<String, dynamic>> fetchAndDecodeJsonData(int id) async {
    final results =
        await DatabaseHelper.instance.fetchResultsByID(id); // Fetch all results
    dynamic jsonData, result;
    for (var row in results) {
      jsonData = jsonDecode(row['abs_data'] as String);
      result = row;
      print("Sample No: ${row['sample_no']}");
    }

    return {'jsonData': jsonData, 'result': result};
  }

  Future<void> _view_details(int id) async {
    final data = await fetchAndDecodeJsonData(id);
    final absData = data["jsonData"];
    final resultData = data["result"];

    final List<FlSpot> spots = (absData['data'] as List)
        .map((item) => FlSpot(
              (item['secs'] as num).toDouble(),
              (item['absorbance_value'] as num).toDouble(),
            ))
        .toList();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleStyle = TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        );

        final labelStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );

        final valueStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black54,
        );

        return AlertDialog(
          title: Text(
            'Details for Sample No: ${resultData['sample_no']}',
            style: titleStyle,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.7, // Limit height
              maxWidth: MediaQuery.of(context).size.width * 0.9, // Limit width
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Type: ',
                        style: labelStyle,
                        children: [
                          TextSpan(
                            text: '${resultData['type']}',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Date: ',
                        style: labelStyle,
                        children: [
                          TextSpan(
                            text: '${resultData['date_time']}',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'HbF: ',
                        style: labelStyle,
                        children: [
                          TextSpan(
                            text: '${resultData['hbf']}',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'HbA1c: ',
                        style: labelStyle,
                        children: [
                          TextSpan(
                            text: '${resultData['hba1c']}',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Remarks: ',
                        style: labelStyle,
                        children: [
                          TextSpan(
                            text: '${resultData['remarks']}',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                SizedBox(
                  height: 300, // Define a fixed height
                  width: 400, // Allow it to take full width
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 130,
                      minY: 0.0,
                      maxY: 1.8,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
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
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 0, 112, 110),
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
                                color: Color.fromARGB(255, 0, 78, 76),
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
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 0, 112, 110),
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
                          color:
                              Color.fromARGB(255, 6, 138, 121).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      backgroundColor: const Color.fromARGB(
                          30, 0, 112, 110), // Background color for the chart
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.teal,
                              Colors.teal,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(71, 14, 122, 61),
                                Color.fromARGB(63, 34, 77, 132),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            cutOffY: null,
                            applyCutOffY: false,
                          ),
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: spots
                              .where((e) => e.x >= 49 && e.x <= 61)
                              .toList(),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.4),
                                Colors.orange.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog_printer(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Print',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text('Do you want to print the details?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Return false
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Return true
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _view_details_and_print(int id) async {
    final data = await fetchAndDecodeJsonData(id);
    final absData = data["jsonData"];
    final resultData = data["result"];

    final List<FlSpot> spots = (absData['data'] as List)
        .map((item) => FlSpot(
              (item['secs'] as num).toDouble(),
              (item['absorbance_value'] as num).toDouble(),
            ))
        .toList();

    await printViewDetailsAndChart(resultData, spots);
  }

  Future<void> printViewDetailsAndChart(
      Map<String, dynamic> resultData, List<FlSpot> spots) async {
    try {
      // Step 1: Format the view details
      List<String> lines = formatPrintData(resultData, spots);

      Uint8List? imageBytes = await captureWidgetToImage(
        chartWidget(spots), // The chart widget to capture
        width: 400,
        height: 300,
      );

      // Step 3: Open the printer port
      var port = SerialPort("/dev/ttyUSB-printer");
      if (!port.openReadWrite()) {
        print('Failed to open port /dev/ttyUSB-printer');
        logEvent("Error", "Failed to open port /dev/ttyUSB-printer",
            page: "result_page");
        return;
      }

      final SerialPortConfig config = SerialPortConfig();
      config.baudRate = 9600;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.bits = 8;
      config.setFlowControl(SerialPortFlowControl.none);
      port.config = config;

      // Step 4: Send the view details line by line
      for (String line in lines) {
        Uint8List data = Uint8List.fromList(line.codeUnits);
        port.write(data); // Send the current line
        port.write(Uint8List.fromList([0x0A])); // Add a line feed
        port.flush();
        await Future.delayed(
            Duration(milliseconds: 200)); // Delay between lines
      }

      int height = 1500;
      port.write(Uint8List.fromList([0x1B, 0x40])); // ESC @
      Uint8List? chartImageForPrint = await generateLineChartImageForPrint(
          canvasHeight: height, dataPoints1: spots);
      for (int line = 0; line < height; line++) {
        int offset = line * 48;
        Uint8List lineData = chartImageForPrint!.sublist(offset, offset + 48);

        Uint8List header = Uint8List.fromList([
          0x1B,
          0x23,
          48,
          1,
        ]);

        port.write(Uint8List.fromList(header + lineData));
        await Future.delayed(Duration(milliseconds: 15));
      }
      port.write(Uint8List.fromList([0x0A])); // Add a line feed
      port.flush();

      //   port.write(formatLine("----------------------", alignment: 'center') as Uint8List);
      // port.write(formatLine("Printed:\n ${DateTime.now()}\n", alignment: 'left') as Uint8List);
      // port.write(formatLine("**********************", alignment: 'center') as Uint8List);
      // Step 5: Send the chart image

      // Step 6: Final feed and cut
      await Future.delayed(Duration(milliseconds: 5));
      port.write(Uint8List.fromList("\n".codeUnits));
      port.write(Uint8List.fromList("\n".codeUnits));
      port.write(Uint8List.fromList("---------- END ----------\n".codeUnits));
      port.flush();
      port.close();

      print("View details and chart printed successfully.");
       logEvent("Info", "View details and chart printed successfully.",
            page: "result_page");
    } catch (e) {
       logEvent("Error", "Error printing view details and chart: $e",
            page: "result_page");
      print("Error printing view details and chart: $e");
    }
  }

  String formatLine(String text,
      {int maxLength = 24, String alignment = 'left'}) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength); // Truncate if it exceeds max length
    }

    switch (alignment) {
      case 'center':
        int totalPadding = maxLength - text.length;
        int paddingLeft = totalPadding ~/ 2;
        int paddingRight = totalPadding - paddingLeft;
        return ' ' * paddingLeft + text + ' ' * paddingRight;
      case 'right':
        return text.padLeft(maxLength);
      case 'left':
      default:
        return text.padRight(maxLength);
    }
  }

  GlobalKey chartKey = GlobalKey();

  Future<Uint8List?> generateLineChartImageForPrint(
      {int canvasHeight = 800, required List<FlSpot> dataPoints1}) async {
    try {
      const int canvasWidth = 384; // Printer width in pixels

      // Create a canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()));

      // Draw background
      final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
          backgroundPaint);

      // Draw axes
      final axisPaint = Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 2.0;
      canvas.drawLine(
          Offset(10, 10), Offset(10, canvasHeight - 10), axisPaint); // Y-axis
      canvas.drawLine(Offset(10, canvasHeight - 10),
          Offset(canvasWidth - 10, canvasHeight - 10), axisPaint); // X-axis

      // Data points for line 2 (Highlight Range)
      List<FlSpot> dataPoints2 =
          dataPoints1.where((point) => point.x >= 49 && point.x <= 61).toList();

      // Transform FlSpot to Offset for rendering
      List<Offset> line1Points = dataPoints1.map((e) {
        double x = 10 + ((e.x - 5) * ((canvasWidth - 20) / 110)); // Map x
        double y = canvasHeight - 10 - (e.y * (canvasHeight - 20) / 2); // Map y
        return Offset(x, y);
      }).toList();

      List<Offset> line2Points = dataPoints2.map((e) {
        double x = 10 + ((e.x - 5) * ((canvasWidth - 20) / 110)); // Map x
        double y = canvasHeight - 10 - (e.y * (canvasHeight - 20) / 2); // Map y
        return Offset(x, y);
      }).toList();

      // Draw Line 1
      final line1Paint = Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 2.0;
      for (int i = 0; i < line1Points.length - 1; i++) {
        canvas.drawLine(line1Points[i], line1Points[i + 1], line1Paint);
      }

      // Draw Line 2 (Highlighted)
      final line2Paint = Paint()
        ..color = ui.Color.fromARGB(255, 1, 0, 0) // Red
        ..strokeWidth = 7.0;
      for (int i = 0; i < line2Points.length - 1; i++) {
        canvas.drawLine(line2Points[i], line2Points[i + 1], line2Paint);
      }

      // Highlight the area under Line 2
      final highlightPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, canvasHeight - 10),
          Offset(0, 10),
          [
            ui.Color.fromARGB(255, 0, 0, 0).withOpacity(0.5), // Orange
            ui.Color.fromARGB(255, 0, 0, 0).withOpacity(0.1), // Fading orange
          ],
        );
      for (int i = 0; i < line2Points.length - 1; i++) {
        Path path = Path()
          ..moveTo(line2Points[i].dx, canvasHeight - 10)
          ..lineTo(line2Points[i].dx, line2Points[i].dy)
          ..lineTo(line2Points[i + 1].dx, line2Points[i + 1].dy)
          ..lineTo(line2Points[i + 1].dx, canvasHeight - 10)
          ..close();
        canvas.drawPath(path, highlightPaint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasWidth, canvasHeight);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (byteData == null) return null;

      final img.Image convertedImage = img.Image.fromBytes(
        canvasWidth,
        canvasHeight,
        byteData.buffer.asUint8List(),
        format: img.Format.rgba,
      );
      print('Canvas Width: $canvasWidth');
      print('Canvas Height: $canvasHeight');
      print('Expected ByteData Length: ${canvasWidth * canvasHeight * 4}');
      print('Actual ByteData Length: ${byteData.lengthInBytes}');
      return convertTo1Bit(convertedImage);
    } catch (e) {
      print('Error generating chart image for printing: $e');
      return null;
    }
  }

  Uint8List convertTo1Bit(img.Image image) {
    int width = image.width;
    int height = image.height;
    int bytesPerRow = (width + 7) ~/ 8;
    Uint8List packedData = Uint8List(bytesPerRow * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        int gray = (img.getRed(pixel) * 0.299 +
                img.getGreen(pixel) * 0.587 +
                img.getBlue(pixel) * 0.114)
            .toInt();

        if (gray < 128) {
          int byteIndex = (y * bytesPerRow) + (x ~/ 8);
          int bitIndex = 7 - (x % 8);
          packedData[byteIndex] |= (1 << bitIndex);
        }
      }
    }

    return packedData;
  }

  Widget chartWidget(List<FlSpot> spots) {
    return SizedBox(
      height: 300,
      width: 400,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 130,
          minY: 0.0,
          maxY: 1.8,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 0.2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.black.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  /// Capture a widget to an image
  Future<Uint8List?> captureWidgetToImage(
    Widget widget, {
    required double width,
    required double height,
  }) async {
    try {
      // Create a boundary for rendering
      final RenderRepaintBoundary boundary = RenderRepaintBoundary();

      // Create a pipeline owner for layout and painting
      final PipelineOwner pipelineOwner = PipelineOwner();
      final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
      final RenderView renderView = RenderView(
        configuration: ViewConfiguration(size: Size(width, height)),
        view: WidgetsBinding.instance.platformDispatcher.views.first,
      );
      pipelineOwner.rootNode = renderView;
      renderView.child = boundary;

      // Attach the widget to the rendering tree
      final RenderObjectToWidgetAdapter adapter = RenderObjectToWidgetAdapter(
        container: boundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );
      adapter.attachToRenderTree(buildOwner);

      // Force synchronous layout and paint
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Ensure the boundary is fully painted
      if (boundary.debugNeedsPaint) {
        print("Widget needs painting. Delaying...");
        await Future.delayed(const Duration(milliseconds: 100));
        pipelineOwner.flushPaint();
      }

      // Capture the widget as an image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing widget to image: $e");
      return null;
    }
  }

  List<String> formatPrintData(
      Map<String, dynamic> resultData, List<FlSpot> spots) {
    List<String> lines = [];

    // Split date and time
    String dateTime = resultData['date_time'];
    List<String> dateTimeParts = dateTime.split('T');
    String date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : "Unknown Date";
    String time = dateTimeParts.length > 1 ? dateTimeParts[1] : "Unknown Time";

    // Header
    lines.add(formatLine("**** HbA1C ****", alignment: 'center'));
    lines.add(
        formatLine("Sample No: ${resultData['sample_no']}", alignment: 'left'));
    lines.add(formatLine("Type: ${resultData['type']}", alignment: 'left'));
    lines.add(formatLine("Date: $date", alignment: 'left')); // Add the date
    lines.add(formatLine("Time: $time", alignment: 'left')); // Add the time
    lines.add(formatLine("HbF: ${resultData['hbf']}", alignment: 'left'));
    lines.add(formatLine("HbA1c: ${resultData['hba1c']}", alignment: 'left'));
    lines.add(formatLine("Remarks:", alignment: 'left'));
    lines.add(formatLine("${resultData['remarks']}", alignment: 'left'));
    lines.add(formatLine("----------------------", alignment: 'center'));

    // Chart Data
    lines.add(formatLine("Absorbance Data:", alignment: 'left'));
    for (var spot in spots) {
      String line =
          "T:${spot.x.toStringAsFixed(1)}s A:${spot.y.toStringAsFixed(3)}";
      lines.add(formatLine(line, alignment: 'left'));
    }

    // Footer
    // lines.add(formatLine("----------------------", alignment: 'center'));
    // lines.add(formatLine("Printed:\n ${DateTime.now()}\n", alignment: 'left'));
    // lines.add(formatLine("**********************", alignment: 'center'));

    return lines;
  }

  // Delete selected rows
  void _deleteSelectedRows() {
    _showConfirmationDialog(
      title: "Delete Selected Rows",
      content: "Are you sure you want to delete the selected rows?",
      onConfirm: () async {
        for (int id in selectedRows) {
          await DatabaseHelper.instance
              .deleteResultByID(id); // Delete from database
        }
        setState(() {
          selectedRows.clear(); // Clear selected rows
        });
        _fetchResults(); // Refresh the data
      },
    );
  }

  // Delete all rows
  void _deleteAllRows() {
    _showConfirmationDialog(
      title: "Delete All Rows",
      content: "Are you sure you want to delete all rows?",
      onConfirm: () async {
        await DatabaseHelper.instance
            .deleteAllResults(); // Delete all from database
        setState(() {
          selectedRows.clear(); // Clear selected rows
        });
        _fetchResults(); // Refresh the data
      },
    );
  }

  void _lineFeed() {
    var port = SerialPort("COM5");
    if (!port.openReadWrite()) {
      print('Failed to open port COM5');
      return;
    }

    final SerialPortConfig config = SerialPortConfig();
    config.baudRate = 9600;
    config.parity = SerialPortParity.none;
    config.stopBits = 1;
    config.bits = 8;
    config.setFlowControl(SerialPortFlowControl.none);
    port.config = config;

    port.write(Uint8List.fromList([0x0A])); // Add a line feed
    port.write(Uint8List.fromList([0x0A]));
    port.write(Uint8List.fromList([0x0A]));
    port.flush();
    port.close();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> wifiStatusNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSearchExpanded)
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Search",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(isSearchExpanded ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearchExpanded = !isSearchExpanded;
                      if (!isSearchExpanded) searchText = "";
                    });
                  },
                ),
                DropdownButton<String>(
                  value: filterColumn,
                  onChanged: (String? newValue) {
                    setState(() {
                      filterColumn = newValue!;
                    });
                  },
                  items: <String>[
                    "ID",
                    "Sample No.",
                    "Type",
                    "Date and Time",
                    "HbF(%)",
                    "HbA1c(%)",
                    "Remarks"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Fixed Header
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Expanded(
                    child: Text("ID",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Sample No.",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Type",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Date and Time",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("HbF(%)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("HbA1c(%)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Remarks",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Scrollable Rows
          Expanded(
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _verticalScrollController,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final row = data[index];
                  final int id = row["id"]; // Ensure ID is an integer

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedRows.contains(id)) {
                          selectedRows.remove(id);
                        } else {
                          selectedRows.add(id);
                        }
                      });
                    },
                    child: Container(
                      color: index % 2 == 0
                          ? (selectedRows.contains(id)
                              ? const Color.fromARGB(255, 187, 251, 218)
                              : Colors.grey[100])
                          : (selectedRows.contains(id)
                              ? const Color.fromARGB(255, 187, 251, 218)
                              : Colors.white),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(id.toString())),
                          Expanded(child: Text(row["sample_no"] ?? "")),
                          Expanded(child: Text(row["type"] ?? "")),
                          Expanded(child: Text(row["date_time"] ?? "")),
                          Expanded(child: Text(row["hbf"].toString())),
                          Expanded(child: Text(row["hba1c"].toString())),
                          Expanded(child: Text(row["remarks"] ?? "")),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Action Buttons
          if (selectedRows.isNotEmpty || data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (selectedRows.isNotEmpty)
                    ElevatedButton(
                      onPressed: _deleteSelectedRows,
                      child: const Text("Delete Selected Rows"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                    ),
                  if (data.isNotEmpty)
                    ElevatedButton(
                      onPressed: _deleteAllRows,
                      child: const Text("Delete All Rows"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                    ),
                  if (data.isNotEmpty)
                    ElevatedButton(
                      onPressed: _lineFeed,
                      child: const Text("Line Feed"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                    ),
                  if (selectedRows.length == 1)
                    ElevatedButton(
                      onPressed: () async {
                        int _id = selectedRows[0];
                        _view_details(_id);
                      },
                      child: const Text("View Details"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                    ),
                  if (selectedRows.length == 1)
                    ElevatedButton(
                      onPressed: () async {
                        int _id = selectedRows[0];
                        if (await _showConfirmationDialog_printer(context) ??
                            false) _view_details_and_print(_id);
                      },
                      child: const Text('Print Chart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),
                        foregroundColor: Color(0xFFFFFFFF),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: CurvedBottomNavigationBar(
        onBackToMenu: widget.onBackToMenu,
        wifiStatusNotifier: wifiStatusNotifier,
        isStarted: false,
      ),
    );
  }
}
