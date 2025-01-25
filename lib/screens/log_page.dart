// LogPage.dart
import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
import 'package:intl/intl.dart';

class LogPage extends StatefulWidget {

  const LogPage({Key? key, required this.onBackToMenu}) : super(key: key);
  final VoidCallback onBackToMenu;
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Map<String, dynamic>> logs = [];
  String selectedTypeFilter = "All";
  String selectedPageFilter = "All";
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    logEvent('info', 'LogPage initialized.', 'log_page');
    fetchLogs();
  }

  Future<void> fetchLogs() async {
   // logEvent('info', 'Fetching logs with filters applied.', 'log_page');
    List<Map<String, dynamic>> allLogs = await DatabaseHelper.instance.getAllLogs();

    setState(() {
      logs = allLogs.where((log) {
        if (selectedTypeFilter != "All" && log['type'] != selectedTypeFilter.toLowerCase()) {
          return false;
        }
        if (selectedPageFilter != "All" && log['page'] != selectedPageFilter.toLowerCase()) {
          return false;
        }
        if (selectedStartDate != null) {
          DateTime logDate = DateFormat('yyyy-MM-dd').parse(log['date']);
          if (logDate.isBefore(selectedStartDate!)) {
            return false;
          }
        }
        if (selectedEndDate != null) {
          DateTime logDate = DateFormat('yyyy-MM-dd').parse(log['date']);
          if (logDate.isAfter(selectedEndDate!)) {
            return false;
          }
        }
        if (searchController.text.isNotEmpty && !log['message'].toLowerCase().contains(searchController.text.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();
    });

    logEvent('info', 'Logs fetched successfully: ${logs.length} entries.', 'log_page');
  }

  Future<void> selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });
    //  logEvent('info', 'Start date selected: ${pickedDate.toIso8601String()}', 'log_page');
      fetchLogs();
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
      });
     // logEvent('info', 'End date selected: ${pickedDate.toIso8601String()}', 'log_page');
      fetchLogs();
    }
  }

  Future<void> logEvent(String type, String message, String page) async {
    await DatabaseHelper.instance.logEvent(type, message, page: page);
    print("$type: $message");
  }

  Color getRowColor(String type) {
    switch (type.toLowerCase()) {
      case 'error':
        return Colors.red.shade100;
      case 'warning':
        return Colors.yellow.shade100;
      case 'info':
        return Colors.green.shade100;
      default:
        return Colors.white;
    }
  }


  final ValueNotifier<bool> wifiStatusNotifier = ValueNotifier(false);

  
  @override
 Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
    children: [
    Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Search Bar
                  Expanded(
                    flex: 2,
                    child: // Search Bar
SizedBox(
  height: 40, // Set the desired height
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      labelText: "Search Logs",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 8, // Reduce vertical padding
        horizontal: 12, // Adjust horizontal padding as needed
      ),
      prefixIcon: Icon(Icons.search, color: Colors.teal),
    ),
    onChanged: (value) {
      fetchLogs();
    },
  ),
),

                  ),
                  const SizedBox(width: 8),

                  // Type Filter Dropdown
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type Filter:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTypeFilter,
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  selectedTypeFilter = value!;
                                });
                               // logEvent('info', 'Type filter changed to: $value', 'log_page');
                                fetchLogs();
                              },
                              items: ["All", "Info", "Error", "Warning"].map((filter) {
                                return DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Page Filter Dropdown
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Page Filter:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPageFilter,
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  selectedPageFilter = value!;
                                });
                                logEvent('info', 'Page filter changed to: $value', 'log_page');
                                fetchLogs();
                              },
                              items: ["All", "log_page", "another_page"].map((page) {
                                return DropdownMenuItem(
                                  value: page,
                                  child: Text(page),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Date Filter Section
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date Filter:", style: TextStyle(fontWeight: FontWeight.bold)),
                       
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => selectStartDate(context),
                              child: Text(
                                selectedStartDate == null
                                    ? "Start Date"
                                    : DateFormat('yyyy-MM-dd').format(selectedStartDate!),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // End Date Picker
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => selectEndDate(context),
                              child: Text(
                                selectedEndDate == null
                                    ? "End Date"
                                    : DateFormat('yyyy-MM-dd').format(selectedEndDate!),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
         

      // Logs Table
      logs.isEmpty
          ? Expanded(
              child: Center(child: Text("No logs available.")),
            )
          : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Page")),
                      DataColumn(label: Text("Message")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Time")),
                      DataColumn(label: Text("Type")),
                    ],
                    rows: logs.map((log) {
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return getRowColor(log['type']);
                          },
                        ),
                        cells: [
                          DataCell(Text(log['id'].toString())),
                          DataCell(Text(log['page'])),
                          DataCell(Text(log['message'])),
                          DataCell(Text(log['date'])),
                          DataCell(Text(log['time'])),
                          DataCell(Text(log['type'].toUpperCase())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    ],
    ),
     bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu, wifiStatusNotifier: wifiStatusNotifier, isStarted: false,),
  );
}
}