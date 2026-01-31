import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/repositories/stock_movement_repository.dart';
import 'package:kioske/models/stock_movement.dart';

class StockAnalyticsModal extends StatefulWidget {
  final String productName;
  final String? productId;

  const StockAnalyticsModal({
    super.key,
    required this.productName,
    this.productId,
  });

  @override
  State<StockAnalyticsModal> createState() => _StockAnalyticsModalState();
}

class _StockAnalyticsModalState extends State<StockAnalyticsModal> {
  String _selectedPeriod = "semaine";
  final StockMovementRepository _movementRepo = StockMovementRepository();

  bool _isLoading = true;
  int _totalIn = 0;
  int _totalOut = 0;
  int _netChange = 0;
  int _transactionCount = 0;
  List<StockMovement> _movements = [];
  Map<DateTime, int> _stockHistory = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (widget.productId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime start;

      switch (_selectedPeriod) {
        case 'semaine':
          start = now.subtract(const Duration(days: 7));
          break;
        case 'mois':
          start = now.subtract(const Duration(days: 30));
          break;
        case 'annee':
          start = now.subtract(const Duration(days: 365));
          break;
        default:
          start = now.subtract(const Duration(days: 7));
      }

      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final movements = await _movementRepo.getByDateRange(
        start,
        end,
        productId: widget.productId,
      );

      int totalIn = 0;
      int totalOut = 0;
      Map<DateTime, int> stockHistory = {};

      for (final movement in movements) {
        if (movement.type == 'in') {
          totalIn += movement.quantity;
        } else if (movement.type == 'out') {
          totalOut += movement.quantity;
        }

        final day = DateTime(
          movement.createdAt.year,
          movement.createdAt.month,
          movement.createdAt.day,
        );
        stockHistory[day] = movement.newStock;
      }

      setState(() {
        _totalIn = totalIn;
        _totalOut = totalOut;
        _netChange = totalIn - totalOut;
        _transactionCount = movements.length;
        _movements = movements;
        _stockHistory = stockHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading stock analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1200,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${l10n.stockAnalytics} - ${widget.productName}",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Period Selector
            Row(
              children: [
                _buildPeriodButton(l10n.week, "semaine"),
                const SizedBox(width: 8),
                _buildPeriodButton(l10n.month, "mois"),
                const SizedBox(width: 8),
                _buildPeriodButton(l10n.year, "annee"),
              ],
            ),
            const SizedBox(height: 24),

            // Key Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    l10n.totalStockIn,
                    _totalIn.toString(),
                    const Color(0xFFE3F2FD),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    l10n.totalStockOut,
                    _totalOut.toString(),
                    const Color(0xFFF1F8E9),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    l10n.netChange,
                    _netChange >= 0 ? "+$_netChange" : "$_netChange",
                    const Color(0xFFF3E5F5),
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    l10n.transactions,
                    _transactionCount.toString(),
                    const Color(0xFFFFF3E0),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildChartCard(
                            l10n.stockEvolution,
                            _buildLineChart(),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildChartCard(
                            l10n.inVsOut,
                            _buildBarChart(),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // History Table Header
            Text(
              l10n.stockHistory,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // History Table
            Expanded(
              flex: 1,
              child: _movements.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun mouvement pour cette période',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                            ),
                            children: [
                              _tableHeader(l10n.dateTime),
                              _tableHeader(l10n.type),
                              _tableHeader('Raison'),
                              _tableHeader(l10n.quantity),
                              _tableHeader(l10n.finalStock),
                            ],
                          ),
                          ..._movements.take(10).map((movement) {
                            return TableRow(
                              children: [
                                _tableCell(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(movement.createdAt),
                                ),
                                _tableCell(
                                  movement.type == 'in'
                                      ? 'Entrée'
                                      : (movement.type == 'out'
                                            ? 'Sortie'
                                            : 'Ajustement'),
                                ),
                                _tableCell(movement.reason ?? '-'),
                                _tableCell(
                                  "${movement.type == 'in' ? '+' : '-'}${movement.quantity}",
                                ),
                                _tableCell(
                                  "${movement.newStock}",
                                  isBold: true,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _loadAnalytics();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (_stockHistory.isEmpty) {
      return const Center(
        child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)),
      );
    }

    final sortedDays = _stockHistory.keys.toList()..sort();
    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < sortedDays.length; i++) {
      final value = (_stockHistory[sortedDays[i]] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
      if (value > maxY) maxY = value;
    }

    if (maxY == 0) maxY = 10;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= sortedDays.length) return const SizedBox();
                final date = sortedDays[val.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) => Text(
                val.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        minX: 0,
        maxX: (sortedDays.length - 1).toDouble().clamp(0, 100),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_totalIn > _totalOut ? _totalIn : _totalOut).toDouble() * 1.2,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val == 0) {
                  return const Text('Entrée', style: TextStyle(fontSize: 10));
                }
                if (val == 1) {
                  return const Text('Sortie', style: TextStyle(fontSize: 10));
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, meta) => Text(
                val.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: _totalIn.toDouble(),
                color: Colors.green,
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: _totalOut.toDouble(),
                color: Colors.red,
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
