import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialReader {
  final String selectedPort;
  SerialPort? port;
  SerialPortReader? reader;
  Stream<List<int>>? serialStream;

  SerialReader(this.selectedPort);

  bool init() {
    try {
      port = SerialPort(selectedPort);
      if (!port!.openReadWrite()) {
        throw Exception('Failed to open port: $selectedPort');
      }

      final config = SerialPortConfig();
      config.baudRate = 9600; // Adjust baud rate if necessary
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.bits = 8;
      config.setFlowControl(SerialPortFlowControl.none);
      port!.config = config;

      reader = SerialPortReader(port!);
      serialStream = reader!.stream;
      return true; // Return true if initialization succeeds
    } catch (e) {
      print('Error initializing serial port: $e');
      return false; // Return false if there is an error
    }
  }

  void dispose() {
    reader?.close();
    port?.close();
  }

  Stream<List<int>>? getStream() => serialStream;
}
