import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/repositories/order_repository.dart';
import 'package:kioske/models/order.dart';

class ProductAnalyticsModal extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductAnalyticsModal({super.key, required this.product});

  @override
  State<ProductAnalyticsModal> createState() => _ProductAnalyticsModalState();
}

class _ProductAnalyticsModalState extends State<ProductAnalyticsModal> {
  String _selectedPeriod = 'week';
  final OrderRepository _orderRepository = OrderRepository();

  bool _isLoading = true;
  int _totalSales = 0;
  double _totalRevenue = 0;
  double _totalProfit = 0;
  double _averageMargin = 0;
  List<Order> _orders = [];
  Map<DateTime, double> _dailySales = {};
  Map<DateTime, double> _dailyProfit = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime start;

      switch (_selectedPeriod) {
        case 'week':
          start = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          start = now.subtract(const Duration(days: 30));
          break;
        case 'year':
          start = now.subtract(const Duration(days: 365));
          break;
        default:
          start = now.subtract(const Duration(days: 7));
      }

      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final orders = await _orderRepository.getByDateRange(start, end);

      // Filter orders that contain this product
      final productId = widget.product['id'] as String?;
      final productName = widget.product['name'] as String;
      final purchasePrice =
          (widget.product['purchasePrice'] as num?)?.toDouble() ?? 0;
      final salePrice = (widget.product['salePrice'] as num?)?.toDouble() ?? 0;
      final unitMargin = salePrice - purchasePrice;

      int totalQuantity = 0;
      double totalRevenue = 0;
      double totalProfit = 0;
      Map<DateTime, double> dailySales = {};
      Map<DateTime, double> dailyProfit = {};
      List<Order> productOrders = [];

      for (final order in orders) {
        if (order.status != 'completed') continue;

        for (final item in order.items) {
          // Match by ID or name
          if ((productId != null && item.productId == productId) ||
              item.productName == productName) {
            totalQuantity += item.quantity;
            totalRevenue += item.total;
            totalProfit += unitMargin * item.quantity;

            // Aggregate by day
            final day = DateTime(
              order.createdAt.year,
              order.createdAt.month,
              order.createdAt.day,
            );
            dailySales[day] = (dailySales[day] ?? 0) + item.total;
            dailyProfit[day] =
                (dailyProfit[day] ?? 0) + (unitMargin * item.quantity);

            if (!productOrders.contains(order)) {
              productOrders.add(order);
            }
          }
        }
      }

      setState(() {
        _totalSales = totalQuantity;
        _totalRevenue = totalRevenue;
        _totalProfit = totalProfit;
        _averageMargin = totalRevenue > 0
            ? (totalProfit / totalRevenue) * 100
            : 0;
        _orders = productOrders;
        _dailySales = dailySales;
        _dailyProfit = dailyProfit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading analytics: $e');
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(value)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey.shade50,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: isLargeScreen ? 1100 : screenWidth * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
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
                      l10n.analyticsTitle(widget.product['name']),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Period Toggle
            Row(
              children: [
                _buildPeriodToggle(l10n.week, 'week'),
                const SizedBox(width: 8),
                _buildPeriodToggle(l10n.month, 'month'),
                const SizedBox(width: 8),
                _buildPeriodToggle(l10n.year, 'year'),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KPI Cards
                          _buildKPIGrid(context, l10n),
                          const SizedBox(height: 24),

                          // Charts
                          Row(
                            children: [
                              Expanded(
                                child: _buildChart(
                                  l10n.salesEvolution,
                                  _buildLineChart(),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildChart(
                                  l10n.profitEvolution,
                                  _buildBarChart(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Detailed Transactions Table
                          Text(
                            l10n.detailedTransactions,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailedTransactionsTable(context, l10n),
                          const SizedBox(height: 32),

                          // Product Details
                          Text(
                            l10n.productDetails,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInfoSection(l10n.generalInfo, [
                                  {l10n.productName: widget.product['name']},
                                  {
                                    l10n.category:
                                        widget.product['category'] ?? 'Unknown',
                                  },
                                  {
                                    l10n.currentStock:
                                        widget.product['stock']?.toString() ??
                                        '0',
                                  },
                                ]),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildInfoSection(l10n.financialInfo, [
                                  {
                                    l10n.purchasePrice: _formatCurrency(
                                      (widget.product['purchasePrice'] as num?)
                                              ?.toDouble() ??
                                          0,
                                    ),
                                  },
                                  {
                                    l10n.salePrice: _formatCurrency(
                                      (widget.product['salePrice'] as num?)
                                              ?.toDouble() ??
                                          0,
                                    ),
                                    'color': Colors.green,
                                  },
                                  {
                                    l10n.unitMargin: _formatCurrency(
                                      ((widget.product['salePrice'] as num?)
                                                  ?.toDouble() ??
                                              0) -
                                          ((widget.product['purchasePrice']
                                                      as num?)
                                                  ?.toDouble() ??
                                              0),
                                    ),
                                    'color': Colors.blue,
                                  },
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(String label, String value) {
    bool isSelected = _selectedPeriod == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _loadAnalytics();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKPIGrid(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            l10n.totalSales,
            _totalSales.toString(),
            const Color(0xFFE3F2FD),
            Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            l10n.totalRevenue,
            _formatCurrency(_totalRevenue),
            const Color(0xFFE8F5E9),
            Colors.green.shade800,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            l10n.totalProfit,
            _formatCurrency(_totalProfit),
            const Color(0xFFF3E5F5),
            Colors.purple.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            l10n.averageMargin,
            "${_averageMargin.toStringAsFixed(1)}%",
            const Color(0xFFFFF3E0),
            Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: text.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String title, Widget chart) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    if (_dailySales.isEmpty) {
      return const Center(
        child: Text(
          'Aucune vente pour cette période',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sortedDays = _dailySales.keys.toList()..sort();
    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < sortedDays.length; i++) {
      final value = _dailySales[sortedDays[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), value));
      if (value > maxY) maxY = value;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (val, meta) => Text(
                _formatShortCurrency(val),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
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
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        minX: 0,
        maxX: (sortedDays.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue.shade400,
            barWidth: 2,
            isStrokeCapRound: true,
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

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildBarChart() {
    if (_dailyProfit.isEmpty) {
      return const Center(
        child: Text(
          'Aucun bénéfice pour cette période',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sortedDays = _dailyProfit.keys.toList()..sort();
    double maxY = 0;

    for (final day in sortedDays) {
      final value = _dailyProfit[day] ?? 0;
      if (value > maxY) maxY = value;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (val, meta) => Text(
                _formatShortCurrency(val),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
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
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        barGroups: sortedDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final value = _dailyProfit[day] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: const Color(0xFF9061F9),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedTransactionsTable(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Aucune transaction pour cette période',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final productName = widget.product['name'] as String;
    final productId = widget.product['id'] as String?;
    final salePrice = (widget.product['salePrice'] as num?)?.toDouble() ?? 0;
    final purchasePrice =
        (widget.product['purchasePrice'] as num?)?.toDouble() ?? 0;
    final unitMargin = salePrice - purchasePrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columnSpacing: 24,
          columns: [
            DataColumn(
              label: Text(l10n.dateTime.toUpperCase(), style: _headerStyle),
            ),
            DataColumn(
              label: Text(l10n.client.toUpperCase(), style: _headerStyle),
            ),
            DataColumn(
              label: Text(l10n.quantity.toUpperCase(), style: _headerStyle),
            ),
            DataColumn(
              label: Text(l10n.unitPrice.toUpperCase(), style: _headerStyle),
            ),
            DataColumn(
              label: Text(l10n.totalPrice.toUpperCase(), style: _headerStyle),
            ),
            DataColumn(label: Text('PROFIT', style: _headerStyle)),
          ],
          rows: _orders.take(20).map((order) {
            // Find the item for this product
            final item = order.items.firstWhere(
              (i) =>
                  (productId != null && i.productId == productId) ||
                  i.productName == productName,
            );

            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(order.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('HH:mm:ss').format(order.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    order.customerId != null ? 'Client' : l10n.anonymousClient,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    _formatCurrency(item.unitPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    _formatCurrency(item.total),
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _formatCurrency(unitMargin * item.quantity),
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  TextStyle get _headerStyle => const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Colors.grey,
  );

  Widget _buildInfoSection(String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final key = item.keys.first;
            final value = item[key];
            final color = item['color'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(key, style: TextStyle(color: Colors.grey.shade500)),
                  Text(
                    value?.toString() ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
