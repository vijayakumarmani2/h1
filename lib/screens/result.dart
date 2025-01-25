import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';

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
  List<int> selectedRows = []; // List of selected row IDs

  @override
  void initState() {
    super.initState();
    _fetchResults(); // Fetch data from DB
  }

  // Fetch results from the database
  Future<void> _fetchResults() async {
    final results = await DatabaseHelper.instance.fetchResults(); // Fetch all rows
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

  // Delete selected rows
  void _deleteSelectedRows() {
    _showConfirmationDialog(
      title: "Delete Selected Rows",
      content: "Are you sure you want to delete the selected rows?",
      onConfirm: () async {
        for (int id in selectedRows) {
          await DatabaseHelper.instance.deleteResultByID(id); // Delete from database
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
        await DatabaseHelper.instance.deleteAllResults(); // Delete all from database
        setState(() {
          selectedRows.clear(); // Clear selected rows
        });
        _fetchResults(); // Refresh the data
      },
    );
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
                        backgroundColor: const Color.fromARGB(162, 67, 154, 93),foregroundColor: Color( 0xFFFFFFFF),
                      ),
                    ),
                  if (data.isNotEmpty)
                    ElevatedButton(
                      onPressed: _deleteAllRows,
                      child: const Text("Delete All Rows"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(162, 29, 60, 139),foregroundColor: Color( 0xFFFFFFFF),
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
      ),
    );
  }
}
