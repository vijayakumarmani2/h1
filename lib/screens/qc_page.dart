import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hba1c_analyzer_1/widget/BottomNavigationBar.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> levels = [
    {
      "level": "Low (#1)",
      "target": 5.50,
      "1SD": 0.10,
      "2SD": 0.20,
      "3SD": 0.30
    },
    {
      "level": "High (#2)",
      "target": 10.30,
      "1SD": 0.10,
      "2SD": 0.20,
      "3SD": 0.30
    },
  ];
  DateTime selectedDate = DateTime(2024, 12);
  DateTimeRange? selectedDateRange;

  String selectedLevel = "Low (#1)";
  String selectedLotNumber = "GSX1230020";

  double mean = 5.5, sd = 0.3, cv = 0.0;

  final DateTime _refDate = DateTime(2024, 1, 1);
  final List<QCPoint> _qcPoints = [];
  final List<QCPoint> _filteredPoints = [];

  @override
  void initState() {
    super.initState();
    _generateInitialData();
    _applyFilters();
  }

  void _generateInitialData() {
    final random = Random();
    for (int i = 0; i < 10; i++) {
      final yValue = randomInRange(random, 4.7, 5); // Range [5, 15]
      final yValueSecondary = randomInRange(random, 4.7, 6); // Range [10, 20]
      _qcPoints.add(QCPoint(i.toDouble(), yValue));
    }
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
            color: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  _QCDataCard(lotNumber: lotNumber, levels: levels),
                  _QCInfoCard(
                      date: selectedDate,
                      onPickDate: _pickYearMonth,
                      mean: mean,
                      sd: sd,
                      cv: cv),
                 
                ],
              ),
            ),
             // Filters Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Level Filter
                    Row(
                      children: [
                        const Text("Level: "),
                      DropdownButton<String>(
  value: selectedLevel,
  items: levels
      .map<DropdownMenuItem<String>>(
        (level) => DropdownMenuItem<String>(
          value: level["level"] as String,
          child: Text(level["level"] as String),
        ),
      )
      .toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        selectedLevel = value;
      });
      _applyFilters();
    }
  },
),
],
                    ),

                    // Lot Number Filter
                    Row(
  children: [
    const Text("Lot Number: "),
    DropdownButton<String>(
      value: selectedLotNumber,
      items: [
        "GSX1230020",
        "GSX1230021",
        "GSX1230022",
      ]
          .map<DropdownMenuItem<String>>(
            (lot) => DropdownMenuItem<String>(
              value: lot,
              child: Text(lot),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedLotNumber = value;
          });
          _applyFilters();
        }
      },
    ),
  ],
),

                    // Date Range Filter
                    Row(
                      children: [
                        const Text("Date Range: "),
                        TextButton(
                          onPressed: _pickDateRange,
                          child: Text(selectedDateRange == null
                              ? "Select Date Range"
                              : "${DateFormat("MM/dd/yyyy").format(selectedDateRange!.start)} - ${DateFormat("MM/dd/yyyy").format(selectedDateRange!.end)}"),
                        ),
                      ],
                    ),
                  ],
                ),
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
      ),
      bottomNavigationBar: CurvedBottomNavigationBar(onBackToMenu: widget.onBackToMenu),
     
    );
  }
}

class _QCDataCard extends StatelessWidget {
  final String lotNumber;
  final List<Map<String, dynamic>> levels;

  const _QCDataCard({Key? key, required this.lotNumber, required this.levels})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                
                padding: const EdgeInsets.all(8),
                child:   Text(
                            'QC Data',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Lot No.:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(lotNumber)
                  ]),
            ),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text("Level",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("Target",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("1SD",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("2SD",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text("3SD",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: levels
                    .map((data) => DataRow(cells: [
                          DataCell(Text(data["level"].toString())),
                          DataCell(Text(data["target"].toString())),
                          DataCell(Text(data["1SD"].toString())),
                          DataCell(Text(data["2SD"].toString())),
                          DataCell(Text(data["3SD"].toString())),
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

class _QCInfoCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPickDate;
  final double mean, sd, cv;

  const _QCInfoCard(
      {Key? key,
      required this.date,
      required this.onPickDate,
      required this.mean,
      required this.sd,
      required this.cv})
      : super(key: key);

  String get monthName => [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ][date.month - 1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
                child: Text("QC Info")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text("LOW",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                      Row(children: [
                        const Text("Mean: "),
                        Text(mean.toStringAsFixed(2))
                      ]),
                      Row(children: [
                        const Text("SD: "),
                        Text(sd.toStringAsFixed(2))
                      ]),
                      Row(children: [
                        const Text("CV(%): "),
                        Text(cv.toStringAsFixed(2))
                      ]),
                    ],
                  ),Column(
                    children: [
                      Text("HIGH",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                      Row(children: [
                        const Text("Mean: "),
                        Text(mean.toStringAsFixed(2))
                      ]),
                      Row(children: [
                        const Text("SD: "),
                        Text(sd.toStringAsFixed(2))
                      ]),
                      Row(children: [
                        const Text("CV(%): "),
                        Text(cv.toStringAsFixed(2))
                      ]),
                    ],
                  ),
                ],
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
