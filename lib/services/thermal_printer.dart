import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LineChartPrinterScreen(),
    );
  }
}

class LineChartPrinterScreen extends StatefulWidget {
  @override
  State<LineChartPrinterScreen> createState() => _LineChartPrinterScreenState();
}

class _LineChartPrinterScreenState extends State<LineChartPrinterScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Line Chart Printer')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await printLineChart();
          },
          child: Text('Print Line Chart'),
        ),
      ),
    );
  }

  Future<void> printLineChart() async {
    const String portName = 'COM5'; // Replace with your printer's port

    Uint8List? chartImageForPrint = await generateLineChartImageForPrint();
    if (chartImageForPrint != null) {
      //await writeDataLineByLine(generateReceiptLines());
      await printChartToPrinter(chartImageForPrint, portName);
    } else {
      print('Failed to generate the chart image for printing.');
    }
  }

  // Generate receipt lines as a List<String>
  List<String> generateReceiptLines() {
    return [
      'HbA1c\n',
      'Date: 2025-01-07\n',
      'Time: 18:00:12\n',
      'Type: W.B.\n',
      'Column Temp: 35.0° C\n',
      'Rack Position: 1#\n',
      'Sample No.: SATHISH\n',
      'Number: 0006\n',
      '\n',
      'Peak    Time   ABS    Area    Result\n',
      'HbA1a   12.7   16     428     0.4\n',
      'HbA1b   17.8   36    1792     1.8\n',
      'HbF     25.5    9     433     0.4\n',
      'LA1c+   37.0   15    1572     1.6\n',
      'HbA1c   51.0   51    6031     6.1\n',
      '\n',
      'Total Area: 109747.0\n',
      'HbA1c(IFCC): 43.1 mmol/mol\n',
      'eAG(ADA): 128.1 mg/dl\n',
      'HbA1c(NGSP): 6.1%\n',
      'Reference Range: 4.5% - 6.5%\n',
      '\n'
    ];
  }

  Future<Uint8List?> generateLineChartImageForPrint(
      {int canvasHeight = 1200}) async {
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

  late final SerialPort port;

  Future<void> writeDataLineByLine(List<String> lines) async {
    port = SerialPort("COM5");
    if (!port.openReadWrite()) {
      print('Failed to open port com5');
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
      if (port == null) {
        throw Exception('Printer is not initialized.');
      }

      for (String line in lines) {
        Uint8List data = Uint8List.fromList(line.codeUnits);
        port!.write(data); // Send the current line
        port!.flush(); // Ensure the line is flushed to the printer
        await Future.delayed(
            Duration(milliseconds: 200)); // Delay between lines
      }

      // Add final feed and cut commands
      Uint8List finalCommands = Uint8List.fromList([
        0x1B, 0x64, 0x05, // ESC d 5 (Feed 5 lines)
        0x1B, 0x69 // ESC i (Full cut)
      ]);
      port!.write(finalCommands);
      port!.flush();

      print('Data sent to the printer line by line.');
    } catch (e) {
      print('Error writing data line by line: $e');
    }
  }

  Future<void> printChartToPrinter(
      Uint8List chartImageData, String portName) async {
        port = SerialPort("COM5");
    if (!port.openReadWrite()) {
      print('Failed to open port com5');
      return;
    }

    final SerialPortConfig config = SerialPortConfig();
    config.baudRate = 9600;
    config.parity = SerialPortParity.none;
    config.stopBits = 1;
    config.bits = 8;
    config.setFlowControl(SerialPortFlowControl.none);
    port.config = config;
    const int widthBytes = 48; // Printer width in bytes (384 pixels / 8)
    const int chartHeight = 1200;

    try {
      for (int line = 0; line < chartHeight; line++) {
        int offset = line * widthBytes;
        Uint8List lineData =
            chartImageData.sublist(offset, offset + widthBytes);

        Uint8List header = Uint8List.fromList([
          0x1B,
          0x23,
          widthBytes,
          1,
        ]);

        
        port.write(Uint8List.fromList(header + lineData));
        await Future.delayed(Duration(milliseconds: 5));
      }

      Uint8List finalCommands =
          Uint8List.fromList([0x1B, 0x64, 0x05, 0x1B, 0x69]);
      port.write(finalCommands);

      print('Chart sent to printer.');
    } finally {
      port.close();
    }
  }
}
