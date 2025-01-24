import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hba1c_analyzer_1/services/DataHandler.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
import 'package:intl/intl.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class QCPoint {
  final double x;
  final double y;

  QCPoint(this.x, this.y);
}

class QCPage extends StatefulWidget {
  const QCPage({Key? key, required this.onBackToMenu}) : super(key: key);
  final VoidCallback onBackToMenu;

  @override
  State<QCPage> createState() => _QCPageState();
}

class _QCPageState extends State<QCPage> {
  String lotNumber = "GSX1230020";
  String low_target = "0.0";
  String high_target = "0.0";
   double mean = 5.5, sd = 0.3, cv = 0.0;

  String low_1sd = "0.0";
  String low_2sd = "0.0";
  String low_3sd = "0.0";
  String high_1sd = "0.0";
  String high_2sd = "0.0";
  String high_3sd = "0.0";

  List<Map<String, dynamic>> qc_data = [];

  @override
  void initState() {
    super.initState();
    _fetchQCTarget();
    _applyFilters();
    qc_data = [
      {
        "level": "Low (#1)",
        "target": low_target,
        "1SD": low_1sd,
        "2SD": low_2sd,
        "3SD": low_3sd
      },
      {
        "level": "High (#2)",
        "target": high_target,
        "1SD": high_1sd,
        "2SD": high_2sd,
        "3SD": high_3sd
      },
    ];
  }

  List<Map<String, dynamic>> qc_info = [
    {
      "level": "Low (#1)",
      "Mean": 0,
      "SD": 0,
      "CV(%)": 0,
    },
    {
      "level": "High (#2)",
      "Mean": 0,
      "SD": 0,
      "CV(%)": 0,
    },
  ];
  DateTime selectedDate = DateTime(2024, 12);
  DateTimeRange? selectedDateRange;

  String selectedLevel = "Low (#1)";
  String selectedLotNumber = "GSX1230020";

 

  final DateTime _refDate = DateTime(2024, 1, 1);
  final List<QCPoint> _qcPoints = [];
  final List<QCPoint> _filteredPoints = [];

  Future<void> _fetchQCTarget() async {
    var latestQCTarget = await DatabaseHelper.instance.fetchLatestQCTarget();

    setState(() {
      if (latestQCTarget != null) {
        low_target = latestQCTarget['low_target'].toString();
        high_target = latestQCTarget['high_target'].toString();
      } else {
        print("No records found in qc_target table.");
      }
    });
  }

  Future<void> updateExistingQCTarget(String low, high) async {
    final updatedData = {
      'low_target': low, // Updated low target value
      'high_target': high, // Updated high target value
      'modified_date': DateTime.now().toIso8601String(), // Updated date
    };

    final rowsAffected =
        await DatabaseHelper.instance.updateQCTarget(updatedData);
    print("Updated $rowsAffected record(s) in qc_target table");
    _fetchQCTarget();
  }

  double randomInRange(Random random, double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  void _addRandomDataPoint() {
    final random = Random();
    final double newX = _qcPoints.isNotEmpty ? _qcPoints.last.x + 1 : 0;
    final double newY = randomInRange(random, 4.7, 5); // Range [5, 15]
    final double newYSecondary =
        randomInRange(random, 4.7, 6); // Range [10, 20]

    setState(() {
      _qcPoints.add(QCPoint(newX, newY));
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPoints.clear();
      _filteredPoints.addAll(
        _qcPoints.where((point) {
          // Filter based on level (e.g., Low or High)
          if (selectedLevel == "Low (#1)" && point.y > 5) return false;
          if (selectedLevel == "High (#2)" && point.y <= 5) return false;

          // Filter based on date range
          if (selectedDateRange != null) {
            final pointDate = _refDate.add(Duration(days: point.x.toInt()));
            if (pointDate.isBefore(selectedDateRange!.start) ||
                pointDate.isAfter(selectedDateRange!.end)) {
              return false;
            }
          }

          return true;
        }),
      );
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  String _formatDateLabel(double x) =>
      DateFormat("MM/dd").format(_refDate.add(Duration(days: x.toInt())));

  Future<void> _pickYearMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null)
      setState(() => selectedDate = DateTime(picked.year, picked.month));
  }

  Widget _buildLineChart() {
    if (_qcPoints.isEmpty) {
      return const Center(child: Text("No QC data available."));
    }

    final yMinus3 = mean - 3 * sd,
        yMinus2 = mean - 2 * sd,
        yMinus1 = mean - sd,
        yPlus1 = mean + sd,
        yPlus2 = mean + 2 * sd,
        yPlus3 = mean + 3 * sd;
    final yMean = mean;
    final chartMinY = min(_qcPoints.map((p) => p.y).reduce(min), yMinus3) - 1;
    final chartMaxY = max(_qcPoints.map((p) => p.y).reduce(max), yPlus3) + 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _qcPoints.last.x + 1,
        minY: chartMinY,
        maxY: chartMaxY,
        gridData: FlGridData(drawVerticalLine: true, drawHorizontalLine: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _qcPoints.map((p) => FlSpot(p.x, p.y)).toList(),
            color: Colors.teal,
            barWidth: 3,
            isCurved: false,
          ),
        ],
        extraLinesData: ExtraLinesData(horizontalLines: [
          _horizontalLine(yMinus3, "-3SD", Colors.grey.shade500),
          _horizontalLine(yMinus2, "-2SD", Colors.grey.shade400),
          _horizontalLine(yMinus1, "-1SD", Colors.grey.shade300),
          _horizontalLine(yMean, " M ", const Color.fromARGB(163, 255, 153, 0)),
          _horizontalLine(yPlus1, "+1SD", Colors.grey.shade300),
          _horizontalLine(yPlus2, "+2SD", Colors.grey.shade400),
          _horizontalLine(yPlus3, "+3SD", Colors.grey.shade500),
        ]),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black54,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                'Date: ${_formatDateLabel(spot.x)}\nValue: ${spot.y.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return Container();
                return Text(_formatDateLabel(value),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (chartMaxY - chartMinY) / 6,
              getTitlesWidget: (value, meta) {
                final sdLabels = {
                  yMinus3: "-3SD",
                  yMinus2: "-2SD",
                  yMinus1: "-1SD",
                  yMean: " M ",
                  yPlus1: "+1SD",
                  yPlus2: "+2SD",
                  yPlus3: "+3SD"
                };
                return Text(sdLabels[value] ?? value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  HorizontalLine _horizontalLine(double y, String label, Color color) {
    return HorizontalLine(
      y: y,
      color: color,
      label: HorizontalLineLabel(
        show: true,
        alignment: Alignment.topRight,
        labelResolver: (_) => label,
      ),
    );
  }

  final ValueNotifier<bool> wifiStatusNotifier = ValueNotifier(false);

  void _showPopupDialog() {
    final TextEditingController lowController = TextEditingController();
    final TextEditingController highController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Target Values',
                  style: TextStyle(color: Colors.teal)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TextField for Low Value
                  TextField(
                    controller: lowController,
                    readOnly: true, // Use virtual keyboard only
                    decoration: InputDecoration(
                      labelText: 'Low',
                      labelStyle: TextStyle(color: Colors.teal),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                    onTap: () {
                      _showVirtualKeyboard(
                        controller: lowController,
                        setState: setState,
                      );
                    },
                    cursorColor: Colors.teal,
                  ),
                  const SizedBox(height: 10),
                  // TextField for High Value
                  TextField(
                    controller: highController,
                    readOnly: true, // Use virtual keyboard only
                    decoration: InputDecoration(
                      labelText: 'High',
                      labelStyle: TextStyle(color: Colors.teal),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                    onTap: () {
                      _showVirtualKeyboard(
                        controller: highController,
                        setState: setState,
                      );
                    },
                    cursorColor: Colors.teal,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      
                      updateExistingQCTarget(
                          lowController.text, highController.text);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal)),
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVirtualKeyboard({
    required TextEditingController controller,
    required void Function(void Function()) setState,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller,
                readOnly: true, // Prevent direct editing
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter value...',
                ),
              ),
              const SizedBox(height: 16),
              // Virtual Keyboard
              Expanded(
                child: VirtualKeyboard(
                  type: VirtualKeyboardType.Numeric, // Numeric keyboard
                  postKeyPress: (key) {
                    setState(() {
                      if (key.keyType == VirtualKeyboardKeyType.String) {
                        controller.text += key.text!;
                      } else if (key.keyType == VirtualKeyboardKeyType.Action &&
                          key.action == VirtualKeyboardKeyAction.Backspace) {
                        if (controller.text.isNotEmpty) {
                          controller.text = controller.text
                              .substring(0, controller.text.length - 1);
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _QCDataCard(lotNumber: lotNumber, qc_data: qc_data),
                // Filters Card
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Level Filter
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          Container(
                            width: 162,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12)),
                            child: CustDropDown(
                              items: [
                                CustDropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    "Low",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                CustDropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                              hintText: "Level",
                              borderRadius: 5,
                              onChanged: (val) {
                                print(val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Lot Number Filter
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          Container(
                            width: 162,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12)),
                            child: CustDropDown(
                              items: const [
                                CustDropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    "12131",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                CustDropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    "2324234",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                              hintText: "Lot Number",
                              borderRadius: 5,
                              onChanged: (val) {
                                print(val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date Range Filter
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              selectedDateRange == null
                                  ? "Select Date Range"
                                  : "${DateFormat("MM/dd/yyyy").format(selectedDateRange!.start)} - ${DateFormat("MM/dd/yyyy").format(selectedDateRange!.end)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 12.0,
                              ),
                              backgroundColor: Colors.teal.shade50,
                              foregroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _QCInfoCard(qc_info: qc_info),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(height: 300, child: _buildLineChart()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPopupDialog,
        backgroundColor: Colors.teal, // Set background color to teal
        child: Icon(Icons.edit),
      ),
      bottomNavigationBar: CurvedBottomNavigationBar(
        onBackToMenu: widget.onBackToMenu,
        wifiStatusNotifier: wifiStatusNotifier,
      ),
    );
  }
}

class _QCDataCard extends StatelessWidget {
  final String lotNumber;
  final List<Map<String, dynamic>> qc_data;

  const _QCDataCard({Key? key, required this.lotNumber, required this.qc_data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Card(
        elevation: 0,
        color: const Color.fromARGB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'QC Data',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(4.0),
            //   child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            //     const Text(
            //       "Lot No.",
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 14,
            //         color: Colors.black54,
            //       ),
            //     ),
            //     SizedBox(
            //       width: 3,
            //     ),
            //     Text(
            //       lotNumber,
            //       style: TextStyle(
            //         fontSize: 14,
            //         color: Colors.black87,
            //       ),
            //     )
            //   ]),
            // ),
            DataTable(
              columns: const [
                DataColumn(
                    label: Text(
                  "Level",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )),
                DataColumn(
                    label: Text(
                  "Target",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )),
                DataColumn(
                    label: Text(
                  "1SD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )),
                DataColumn(
                    label: Text(
                  "2SD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )),
                DataColumn(
                    label: Text(
                  "3SD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )),
              ],
              rows: qc_data
                  .map((data) => DataRow(cells: [
                        DataCell(Text(
                          data["level"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        )),
                        DataCell(Text(
                          data["target"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        )),
                        DataCell(Text(
                          data["1SD"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        )),
                        DataCell(Text(
                          data["2SD"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        )),
                        DataCell(Text(
                          data["3SD"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        )),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QCInfoCard extends StatelessWidget {
  final List<Map<String, dynamic>> qc_info;

  const _QCInfoCard({Key? key, required this.qc_info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        elevation: 0,
        color: Color.fromARGB(0, 255, 255, 255),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'QC Info',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text(
                    "Level",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    "Mean",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    "SD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  )),
                  DataColumn(
                      label: Text(
                    "CV(%)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  )),
                ],
                rows: qc_info
                    .map((data) => DataRow(cells: [
                          DataCell(Text(
                            data["level"].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          )),
                          DataCell(Text(
                            data["Mean"].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          )),
                          DataCell(Text(
                            data["SD"].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          )),
                          DataCell(Text(
                            data["CV(%)"].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          )),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnePointCard extends StatelessWidget {
  const _OnePointCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
                child: Text("One Point")),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Placeholder for data")),
          ],
        ),
      ),
    );
  }
}

class CustDropDown<T> extends StatefulWidget {
  final List<CustDropdownMenuItem> items;
  final Function onChanged;
  final String hintText;
  final double borderRadius;
  final double maxListHeight;
  final double borderWidth;
  final int defaultSelectedIndex;
  final bool enabled;

  const CustDropDown(
      {required this.items,
      required this.onChanged,
      this.hintText = "",
      this.borderRadius = 0,
      this.borderWidth = 1,
      this.maxListHeight = 100,
      this.defaultSelectedIndex = -1,
      Key? key,
      this.enabled = true})
      : super(key: key);

  @override
  _CustDropDownState createState() => _CustDropDownState();
}

class _CustDropDownState extends State<CustDropDown>
    with WidgetsBindingObserver {
  bool _isOpen = false, _isAnyItemSelected = false, _isReverse = false;
  late OverlayEntry _overlayEntry;
  late RenderBox? _renderBox;
  Widget? _itemSelected;
  late Offset dropDownOffset;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          dropDownOffset = getOffset();
        });
      }
      if (widget.defaultSelectedIndex > -1) {
        if (widget.defaultSelectedIndex < widget.items.length) {
          if (mounted) {
            setState(() {
              _isAnyItemSelected = true;
              _itemSelected = widget.items[widget.defaultSelectedIndex];
              widget.onChanged(widget.items[widget.defaultSelectedIndex].value);
            });
          }
        }
      }
    });
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  void _addOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry);
  }

  void _removeOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
      _overlayEntry.remove();
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    _renderBox = context.findRenderObject() as RenderBox?;

    var size = _renderBox!.size;

    dropDownOffset = getOffset();

    return OverlayEntry(
        maintainState: false,
        builder: (context) => Align(
              alignment: Alignment.center,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: dropDownOffset,
                child: SizedBox(
                  height: widget.maxListHeight,
                  width: size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: _isReverse
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: widget.maxListHeight,
                              maxWidth: size.width),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.borderRadius),
                            ),
                            child: Material(
                              elevation: 0,
                              color: Colors.teal.shade50,
                              shadowColor: Colors.grey,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: widget.items
                                    .map((item) => GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: item.child,
                                          ),
                                          onTap: () {
                                            if (mounted) {
                                              setState(() {
                                                _isAnyItemSelected = true;
                                                _itemSelected = item.child;
                                                _removeOverlay();
                                                if (widget.onChanged != null)
                                                  widget.onChanged(item.value);
                                              });
                                            }
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Offset getOffset() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    double y = renderBox!.localToGlobal(Offset.zero).dy;
    double spaceAvailable = _getAvailableSpace(y + renderBox.size.height);
    if (spaceAvailable > widget.maxListHeight) {
      _isReverse = false;
      return Offset(0, renderBox.size.height);
    } else {
      _isReverse = true;
      return Offset(
          0,
          renderBox.size.height -
              (widget.maxListHeight + renderBox.size.height));
    }
  }

  double _getAvailableSpace(double offsetY) {
    double safePaddingTop = MediaQuery.of(context).padding.top;
    double safePaddingBottom = MediaQuery.of(context).padding.bottom;

    double screenHeight =
        MediaQuery.of(context).size.height - safePaddingBottom - safePaddingTop;

    return screenHeight - offsetY;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                _isOpen ? _removeOverlay() : _addOverlay();
              }
            : null,
        child: Container(
          decoration: _getDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 3,
                child: _isAnyItemSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: _itemSelected!,
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.only(left: 4.0), // change it here
                        child: Text(
                          widget.hintText,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.clip,
                        ),
                      ),
              ),
              const Flexible(
                flex: 1,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Decoration? _getDecoration() {
    if (_isOpen && !_isReverse) {
      return BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (_isOpen && _isReverse) {
      return BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (!_isOpen) {
      return BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)));
    }
  }
}

class CustDropdownMenuItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const CustDropdownMenuItem({required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
