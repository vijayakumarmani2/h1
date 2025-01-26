import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/services/serial_port_service.dart';

class PrimeCheckPage extends StatefulWidget {
  @override
  _PrimeCheckPageState createState() => _PrimeCheckPageState();
}

class _PrimeCheckPageState extends State<PrimeCheckPage> {
  bool isPrimeCheckButtonVisible = true;
  bool isProcessing = false;
 void logEvent(String type, String message, {required String page}) async {
    await DatabaseHelper.instance.logEvent(type, message, page: page);
    print("$type: $message");
  }
  void sendCommandToSerialPort() async {
    // Simulate sending a command to a serial port and waiting for a response
    setState(() {
      isProcessing = true;
    });

    logEvent('info', 'Serial reader initialization started.',
        page: 'welcome_page');
    var serialReader = SerialReader('/dev/ttyUSB-static');
    // serialReader = SerialReader('COM5');
    if (!serialReader.init()) {
      print(
          'Failed to open serial port /dev/ttyUSB-static. Please check the connection.');
      // Show a SnackBar if the maximum limit is reached
      logEvent('error',
          'Failed to open serial port /dev/ttyUSB-static. Please check the connection.',
          page: 'PrimeCheck');

      print('Failed to open serial port. Please check the connection.');
     
    } else {
      logEvent('info', 'Serial reader initialized successfully.',
          page: 'PrimeCheck');
       
  
      final message = "PCHEC"; // Example message format
      Future.delayed(Duration(seconds: 2), () {
  print("This is executed after a 2-second delay");
});
      serialReader.port?.write(Uint8List.fromList(message.codeUnits));
      print("Sent to hardware: $message");
     
    
     String buffer = '';

      serialReader.getStream()!.listen((data) {
        // Append received data to the buffer
        
        buffer += String.fromCharCodes(data);
        print("buffer: $buffer");
        if (buffer == "PCHECKED") {
          
          print("Initialization completed - ${buffer}");
          logEvent('info', 'Initialization completed - ${buffer}',
          page: 'PrimeCheck');
          setState(() {
      isProcessing = false;
      showSecondPopup();
    });
          buffer = '';
          serialReader.port?.close();
        }
      });

      
    }
  }

  void showSecondPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Prime Check"),
        content: Text("Please ensure the drain valve is closed properly."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              setState(() {
                isPrimeCheckButtonVisible = true; // Show the button again
              });
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void showFirstPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Prime Check"),
        content: Text("Please ensure the drain valve is removed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              sendCommandToSerialPort(); // Proceed with sending the command
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prime Check Page"),
      ),
      body: Center(
        child: isPrimeCheckButtonVisible
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPrimeCheckButtonVisible = false;
                  });
                  showFirstPopup();
                },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal), foregroundColor: MaterialStatePropertyAll(Colors.white)),
                child: Text("Prime Check"),
              )
            : isProcessing
                ? CircularProgressIndicator() // Show loading while waiting for response
                : SizedBox.shrink(), // Empty placeholder when processing is complete
      ),
    );
  }
}
