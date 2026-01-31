import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/employee.dart'; // Import Employee model

class EmployeeAnalyticsModal extends StatefulWidget {
  final Employee employee; // Change to Employee type
  const EmployeeAnalyticsModal({super.key, required this.employee});

  @override
  State<EmployeeAnalyticsModal> createState() => _EmployeeAnalyticsModalState();
}

class _EmployeeAnalyticsModalState extends State<EmployeeAnalyticsModal> {
  int _selectedPeriodIndex = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 100 : 16,
        vertical: 24,
      ),
      child: Container(
        width: 1100,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Analytics - ${widget.employee.name}", // Access via name property
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tabs
            Row(
              children: [
                _buildPeriodTab(l10n.week, 0),
                const SizedBox(width: 12),
                _buildPeriodTab(l10n.month, 1),
                const SizedBox(width: 12),
                _buildPeriodTab(l10n.year, 2),
              ],
            ),
            const SizedBox(height: 24),

            // Content Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.totalSales,
                            "0 FCFA",
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.transactions,
                            "0",
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.avgTransactionColumn,
                            "0 FCFA",
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.salary,
                            "${widget.employee.salary.toStringAsFixed(0)} FCFA", // Access salary property
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Charts Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildChartSection(
                            l10n.salesEvolution,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildChartSection(
                            l10n.transactionsEvolution,
                            Colors.purple.shade200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // History Table
                    Text(
                      l10n.salesHistory,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryTable(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    bool isSelected = _selectedPeriodIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedPeriodIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFFF3F4F6), // Blue if selected, grey if not
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color.shade900,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors
            .white, // In screenshot it seems to be white or very light grey, sticking to white for now but wrapped in "Dashed" border container if needed? Screenshot shows charts in white cards?
        // Actually screenshot shows charts are just on the white background of the modal?
        // Wait, looking at screenshot, the charts are inside some container implicitly. Let's make it a clean container.
        // Or wait, they have a dashed grid.
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Mock Dates: 2026-01-10 to 16
                        // We have mock indexes 0 to 6
                        int index = value.toInt();
                        if (index >= 0 && index <= 6) {
                          // Just showing some labels
                          if (index % 2 == 0) {
                            return Text(
                              "2026-01-${10 + index}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false), // No outside border
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 4,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 0),
                      FlSpot(1, 0),
                      FlSpot(2, 0),
                      FlSpot(3, 0),
                      FlSpot(4, 0),
                      FlSpot(5, 0),
                      FlSpot(6, 0),
                    ],
                    isCurved: false,
                    color: color, // Line color
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: true,
                    ), // Show dots as in screenshot
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Period
          1: FlexColumnWidth(1), // Sales
          2: FlexColumnWidth(1), // Transactions
          3: FlexColumnWidth(1.5), // Avg
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            children: [
              _buildTableCell(l10n.periodColumn, isHeader: true),
              _buildTableCell(l10n.salesColumn, isHeader: true),
              _buildTableCell(l10n.transactionsColumn, isHeader: true),
              _buildTableCell(l10n.avgTransactionColumn, isHeader: true),
            ],
          ),
          // Mock Rows
          _buildHistoryRow("2026-01-10"),
          _buildHistoryRow("2026-01-11"),
          _buildHistoryRow("2026-01-12"),
        ],
      ),
    );
  }

  TableRow _buildHistoryRow(String date) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
      ),
      children: [
        _buildTableCell(date),
        _buildTableCell("0 FCFA", color: Colors.green),
        _buildTableCell("0", color: Colors.blue),
        _buildTableCell("0 FCFA", color: Colors.purple),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.grey.shade500 : (color ?? Colors.black87),
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          fontSize: isHeader ? 12 : 14,
        ),
      ),
    );
  }
}
