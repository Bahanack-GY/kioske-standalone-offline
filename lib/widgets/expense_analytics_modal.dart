import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';

import 'package:kioske/models/expense.dart';

class ExpenseAnalyticsModal extends StatefulWidget {
  final Expense expense;

  const ExpenseAnalyticsModal({super.key, required this.expense});

  @override
  State<ExpenseAnalyticsModal> createState() => _ExpenseAnalyticsModalState();
}

class _ExpenseAnalyticsModalState extends State<ExpenseAnalyticsModal> {
  String _selectedPeriod = 'Mois'; // Default logic, keys map to l10n later

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 900;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? screenSize.width * 0.1 : 16,
        vertical: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeFilter(l10n),
                    const SizedBox(height: 24),
                    _buildSummaryCards(l10n, isLargeScreen),
                    const SizedBox(height: 24),
                    _buildChartsSection(l10n, isLargeScreen),
                    const SizedBox(height: 24),
                    _buildHistorySection(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${l10n.expenseAnalyticsHeader} - ${widget.expense.title}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(widget.expense.status, l10n),
                    const SizedBox(width: 12),
                    // Recurring logic removed for now
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, AppLocalizations l10n) {
    Color color = Colors.orange;
    Color bgColor = Colors.orange.shade100;
    String text = l10n.pending;

    if (status == 'approved') {
      color = Colors.green;
      bgColor = Colors.green.shade100;
      text = l10n.paid;
    } else if (status == 'rejected') {
      color = Colors.red;
      bgColor = Colors.red.shade100;
      text = 'Rejected';
    } else if (status == 'overdue') {
      color = Colors.red;
      bgColor = Colors.red.shade100;
      text = l10n.overdue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeFilter(AppLocalizations l10n) {
    return Row(
      children: [
        _buildTimeChip(l10n.monthLabel, 'Mois'),
        const SizedBox(width: 8),
        _buildTimeChip(l10n.quarterLabel, 'Trimestre'),
        const SizedBox(width: 8),
        _buildTimeChip(l10n.yearLabel, 'Année'),
      ],
    );
  }

  Widget _buildTimeChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = isLargeScreen
            ? (constraints.maxWidth - 48) / 4
            : constraints.maxWidth;

        List<Widget> cards = [
          _buildMetricCard(
            l10n.totalAmount ?? "Montant total", // Fallback if key missing
            "${NumberFormat('#,###').format(widget.expense.amount)} FCFA",
            Colors.blue,
            Colors.blue.shade50,
            width: cardWidth,
          ),
          SizedBox(
            width: isLargeScreen ? 16 : 0,
            height: isLargeScreen ? 0 : 16,
          ),
          _buildMetricCard(
            l10n.paidAmount ?? "Montant payé", // Fallback
            "0 FCFA",
            Colors.green,
            Colors.green.shade50,
            width: cardWidth,
          ),
          SizedBox(
            width: isLargeScreen ? 16 : 0,
            height: isLargeScreen ? 0 : 16,
          ),
          _buildMetricCard(
            l10n.pendingAmount ?? "Montant en attente", // Fallback
            "${NumberFormat('#,###').format(widget.expense.amount)} FCFA",
            Colors.orange,
            Colors.orange.shade50,
            width: cardWidth,
          ),
          SizedBox(
            width: isLargeScreen ? 16 : 0,
            height: isLargeScreen ? 0 : 16,
          ),
          _buildMetricCard(
            l10n.monthlyAverage,
            "${NumberFormat('#,###').format((widget.expense.amount as num) / 4)} FCFA", // Mock calc
            Colors.purple,
            Colors.purple.shade50,
            width: cardWidth,
          ),
        ];

        return isLargeScreen ? Row(children: cards) : Column(children: cards);
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    Color bgColor, {
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(AppLocalizations l10n, bool isLargeScreen) {
    return SizedBox(
      height: 350,
      child: isLargeScreen
          ? Row(
              children: [
                Expanded(child: _buildEvolutionChart(l10n)),
                const SizedBox(width: 24),
                Expanded(child: _buildDistributionChart(l10n)),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildEvolutionChart(l10n)),
                const SizedBox(height: 24),
                Expanded(child: _buildDistributionChart(l10n)),
              ],
            ),
    );
  }

  Widget _buildEvolutionChart(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.amountEvolution,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '2025-10', // Hardcoded for demo
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const Text(
                            '0',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        if (value == 20000) {
                          return const Text(
                            '20000',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        if (value == 40000) {
                          return const Text(
                            '40000',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        if (value == 60000) {
                          return const Text(
                            '60000',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        if (value == 80000) {
                          return const Text(
                            '80000',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 1,
                minY: 0,
                maxY: 80000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [const FlSpot(0.5, 65007)],
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.red,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statusDistribution,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 75,
                    title: '',
                    radius: 80,
                  ),
                  PieChartSectionData(
                    color: Colors.orange.shade300,
                    value: 25,
                    title: '',
                    radius: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyHistory,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.transparent),
                    ),
                  ), // No borders
                  children: [
                    _buildTableHeader(l10n.periodColumn),
                    const SizedBox(width: 40),
                    _buildTableHeader(l10n.expenseAmount), // Or custom key
                    const SizedBox(width: 40),
                    _buildTableHeader(l10n.countColumn),
                    const SizedBox(width: 40),
                    _buildTableHeader(l10n.paidColumn),
                    const SizedBox(width: 40),
                    _buildTableHeader(l10n.pendingColumn),
                    const SizedBox(width: 40),
                    _buildTableHeader(l10n.overdueColumn),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(height: 16),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                  ],
                ), // Spacer
                TableRow(
                  children: [
                    _buildTableCell('2025-10'),
                    const SizedBox(),
                    _buildTableCell(
                      "${NumberFormat('#,###').format(widget.expense.amount)} FCFA",
                      color: Colors.red,
                      isBold: true,
                    ),
                    const SizedBox(),
                    _buildTableCell('4', color: Colors.blue),
                    const SizedBox(),
                    _buildTableCell(
                      "0 FCFA",
                      color: Colors.green,
                      isBold: true,
                    ),
                    const SizedBox(),
                    _buildTableCell(
                      "${NumberFormat('#,###').format(widget.expense.amount)} FCFA",
                      color: Colors.orange,
                      isBold: true,
                    ),
                    const SizedBox(),
                    _buildTableCell("0 FCFA", color: Colors.red, isBold: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? color, bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.black87,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}
