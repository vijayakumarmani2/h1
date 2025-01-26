import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LineChartPrinter(),
    );
  }
}

class LineChartPrinter extends StatefulWidget {
  @override
  _LineChartPrinterState createState() => _LineChartPrinterState();
}

class _LineChartPrinterState extends State<LineChartPrinter> {
  final GlobalKey _chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Line Chart for Printing'),
      ),
      body: Center(
        child: Column(
          children: [
            RepaintBoundary(
              key: _chartKey,
              child: SizedBox(
                height: 300,
                width: 300,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: [
                          FlSpot(0, 1),
                          FlSpot(1, 3),
                          FlSpot(2, 1.5),
                          FlSpot(3, 4),
                          FlSpot(4, 3.5),
                          FlSpot(5, 5),
                          FlSpot(6, 4),
                        ],
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(show: true),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: writeDataLineByLine,
              child: Text('Print Chart'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> writeDataLineByLine() async {
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

    try {
      Uint8List chartData = await _captureAndPrepareImage();

      if (chartData.isEmpty) {
        throw Exception('Failed to generate chart data for printing.');
      }
      int height = 1500;
      // Initialize Printer
      port.write(Uint8List.fromList([0x1B, 0x40])); // ESC @
      Uint8List? chartImageForPrint = await generateLineChartImageForPrint(canvasHeight: height);
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
        await Future.delayed(Duration(milliseconds: 5));
      }
      // Add final feed and cut commands
      Uint8List finalCommands = Uint8List.fromList([
        0x1B, 0x64, 0x05, // ESC d 5 (Feed 5 lines)
        0x1B, 0x69 // ESC i (Full cut)
      ]);
      port.write(finalCommands);
      port.flush();

      print('Data sent to the printer successfully.');
      port.close();
    } catch (e) {
      print('Error writing data: $e');
    }
  }

  final List<FlSpot> dataPoints1 = [
    FlSpot(5, 0.06),
    FlSpot(10, 0.67),
    FlSpot(15, 0.73),
    FlSpot(20, 0.921),
    FlSpot(25, 0.07),
    FlSpot(30, 0.3),
    FlSpot(35, 0.31),
    FlSpot(40, 0.006),
    FlSpot(45, 0.19),
    FlSpot(50, 0.2),
    FlSpot(55, 0.05),
    FlSpot(60, 0.06),
    FlSpot(65, 0.09),
    FlSpot(70, 0.1),
    FlSpot(75, 0.456),
    FlSpot(80, 0.06),
    FlSpot(85, 1.75),
    FlSpot(90, 1.34),
    FlSpot(95, 0.11),
    FlSpot(100, 0.96),
    FlSpot(105, 1.12),
    FlSpot(110, 0.06),
    FlSpot(115, 0.06),
  ];

  
  Future<Uint8List?> generateLineChartImageForPrint(
      {int canvasHeight = 800}) async {
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
          dataPoints1.where((point) => point.x >= 80 && point.x <= 95).toList();

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

  Future<Uint8List> _captureAndPrepareImage() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image chartImage = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await chartImage.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (byteData == null) return Uint8List(0);

      // Convert image to grayscale and threshold to monochrome
      Uint8List grayscaleImage =
          _convertToMonochrome(byteData, chartImage.width, chartImage.height);

      // Format the image for ESC/POS (Bit Image Mode)
      return grayscaleImage;
      // return _formatImageForPrinter(grayscaleImage, chartImage.width, chartImage.height);
    } catch (e) {
      print("Error capturing chart image: $e");
      return Uint8List(0);
    }
  }

  Uint8List _convertToMonochrome(ByteData byteData, int width, int height) {
    // Each byte in the raw RGBA data has 4 channels (R, G, B, A).
    // To create a monochrome bitmap, we need 1 bit per pixel, so each byte in
    // the final data represents 8 pixels.

    // Calculate the number of bytes required for the monochrome bitmap
    int bytesPerRow =
        (width + 7) ~/ 8; // Each row's width in bytes (rounded up)
    Uint8List monochromeBitmap = Uint8List(bytesPerRow * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Get the index of the pixel in the RGBA data
        int pixelIndex = (y * width + x) * 4;

        // Extract the RGBA values
        int r = byteData.getUint8(pixelIndex);
        int g = byteData.getUint8(pixelIndex + 1);
        int b = byteData.getUint8(pixelIndex + 2);

        // Convert to grayscale using luminosity formula
        double grayscale = 0.299 * r + 0.587 * g + 0.114 * b;

        // Apply a threshold to determine black or white
        bool isBlack = grayscale < 128;

        // Update the corresponding bit in the monochrome bitmap
        if (isBlack) {
          // Set the bit (x % 8) in the byte corresponding to this pixel
          monochromeBitmap[y * bytesPerRow + (x ~/ 8)] |= (0x80 >> (x % 8));
        }
      }
    }

    return monochromeBitmap;
  }

  Uint8List _formatImageForPrinter(Uint8List imageData, int width, int height) {
    List<int> command = [];

    // Add ESC/POS command for bit-image mode
    command.addAll([0x1B, 0x23, 0x47, 0x48]);

    // Add image data row by row
    command.addAll(imageData);

    return Uint8List.fromList(command);
  }
}
