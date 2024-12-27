import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final VoidCallback onBackToMenu;

  ResultPage({required this.onBackToMenu});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isSearchExpanded = false;
  String searchText = "";
  String filterColumn = "Number";

  final ScrollController _verticalScrollController = ScrollController();

  List<Map<String, String>> data = [
    {"Number": "0010", "Sample No.": "QC2", "Type": "Diluted blood", "Date and Time": "2024-11-29 14:20:01", "HbF(%)": "1.3", "HbA1c(%)": "10.1*", "Remarks": "-"},
    {"Number": "0009", "Sample No.": "QC1", "Type": "Diluted blood", "Date and Time": "2024-11-29 14:17:50", "HbF(%)": "-", "HbA1c(%)": "-", "Remarks": "-"},
    {"Number": "0008", "Sample No.": "QC2", "Type": "Diluted blood", "Date and Time": "2024-11-28 15:42:07", "HbF(%)": "1.2", "HbA1c(%)": "9.9*", "Remarks": "-"},
    {"Number": "0007", "Sample No.": "QC1", "Type": "Diluted blood", "Date and Time": "2024-11-28 15:39:56", "HbF(%)": "0.3", "HbA1c(%)": "5.5*", "Remarks": "-"},
    {"Number": "0006", "Sample No.": "C2", "Type": "Diluted blood", "Date and Time": "2024-11-28 14:23:40", "HbF(%)": "1.1", "HbA1c(%)": "8.8*", "Remarks": "-"},
    {"Number": "0005", "Sample No.": "C2", "Type": "Diluted blood", "Date and Time": "2024-11-28 14:21:30", "HbF(%)": "1.1", "HbA1c(%)": "8.9*", "Remarks": "-"},
    {"Number": "0004", "Sample No.": "C1", "Type": "Diluted blood", "Date and Time": "2024-11-28 14:19:20", "HbF(%)": "0.2", "HbA1c(%)": "4.8", "Remarks": "-"},
    {"Number": "0003", "Sample No.": "C1", "Type": "Diluted blood", "Date and Time": "2024-11-28 14:17:10", "HbF(%)": "0.3", "HbA1c(%)": "4.7", "Remarks": "-"},
    {"Number": "0002", "Sample No.": "S2", "Type": "Whole blood", "Date and Time": "2024-11-28 13:54:55", "HbF(%)": "-", "HbA1c(%)": "-", "Remarks": "e1"},
    {"Number": "0001", "Sample No.": "S1", "Type": "Whole blood", "Date and Time": "2024-11-28 13:52:46", "HbF(%)": "-", "HbA1c(%)": "-", "Remarks": "e1"},
  ];

  List<int> selectedRows = [];

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
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  void _deleteSelectedRows() {
    _showConfirmationDialog(
      title: "Delete Selected Rows",
      content: "Are you sure you want to delete the selected rows?",
      onConfirm: () {
        setState(() {
          data.removeWhere((row) => selectedRows.contains(data.indexOf(row)));
          selectedRows.clear();
        });
      },
    );
  }

  void _deleteAllRows() {
    _showConfirmationDialog(
      title: "Delete All Rows",
      content: "Are you sure you want to delete all rows?",
      onConfirm: () {
        setState(() {
          data.clear();
          selectedRows.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }
  

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
                        decoration: InputDecoration(
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
                  items: <String>["Number", "Sample No.", "Type", "Date and Time", "HbF(%)", "HbA1c(%)", "Remarks"]
                      .map<DropdownMenuItem<String>>((String value) {
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
              children: [
                Expanded(child: Text("Number", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Sample No.", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Date and Time", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("HbF(%)", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("HbA1c(%)", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Remarks", style: TextStyle(fontWeight: FontWeight.bold))),
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
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedRows.contains(index)) {
                          selectedRows.remove(index);
                        } else {
                          selectedRows.add(index);
                        }
                      });
                    },
                    child: Container(
                      color: index % 2 == 0
                          ? (selectedRows.contains(index) ? const Color.fromARGB(255, 187, 251, 218) : Colors.grey[100])
                          : (selectedRows.contains(index) ? const Color.fromARGB(255, 187, 251, 218) : Colors.white),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(row["Number"]!)),
                          Expanded(child: Text(row["Sample No."]!)),
                          Expanded(child: Text(row["Type"]!)),
                          Expanded(child: Text(row["Date and Time"]!)),
                          Expanded(child: Text(row["HbF(%)"]!)),
                          Expanded(child: Text(row["HbA1c(%)"]!)),
                          Expanded(child: Text(row["Remarks"]!)),
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
                  if (selectedRows.isNotEmpty )
                    ElevatedButton(
                      onPressed: _deleteSelectedRows,
                      child: Text("Delete Selected Rows"),style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(162, 67, 154, 93),
                                  ),
                    ),
                  if (selectedRows.isNotEmpty )
                    ElevatedButton(
                      onPressed: _deleteAllRows,
                      child: Text("Delete All Rows"),style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(162, 29, 60, 139),
                                  ),
                    ),
                ],
              ),
            ),
        Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2), // Shadow color with opacity
        blurRadius: 10, // Amount of blur
        offset: Offset(0, 5), // Offset in X and Y direction
      ),
    ],
    shape: BoxShape.circle, // Ensures shadow follows the circular button
  ),
  child: FloatingActionButton(
    onPressed: widget.onBackToMenu,
    child: Icon(Icons.home, size: 35),
    backgroundColor: Color(0xFF00706e),
    elevation: 0, // Disable default elevation to avoid double shadow
  ),
)

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onBackToMenu,
       
        child: Icon(Icons.home,size: 35,), 
        backgroundColor: Color(0xFF00706e),
        elevation: 5,
       
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

