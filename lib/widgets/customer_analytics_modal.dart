import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';

import 'package:kioske/models/customer.dart';

class CustomerAnalyticsModal extends StatefulWidget {
  final Customer customer;

  const CustomerAnalyticsModal({super.key, required this.customer});

  @override
  State<CustomerAnalyticsModal> createState() => _CustomerAnalyticsModalState();
}

class _CustomerAnalyticsModalState extends State<CustomerAnalyticsModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Cette année';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    _buildSummaryCards(l10n, isLargeScreen),
                    const SizedBox(height: 24),
                    _buildChartsSection(l10n, isLargeScreen),
                    const SizedBox(height: 24),
                    Text(
                      l10n.consumptionHabits,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHabitsGrid(l10n, isLargeScreen),
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
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFFA855F7)], // Blue to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerAnalytics,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.customer.name} - ${widget.customer.phone ?? ''}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    dropdownColor: const Color(0xFFA855F7),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedPeriod = value);
                    },
                    items: ['Ce mois', 'Cette année', 'Toujours']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 3 cards with spacing
        // If not large screen, stack them or scroll
        double cardWidth = isLargeScreen
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth;

        List<Widget> cards = [
          _buildMetricCard(
            l10n.totalPurchases,
            "${widget.customer.totalPurchases}",
            Icons.trending_up,
            Colors.blue,
            const Color(0xFFEFF6FF),
            width: cardWidth,
          ),
          SizedBox(
            width: isLargeScreen ? 16 : 0,
            height: isLargeScreen ? 0 : 16,
          ),
          _buildMetricCard(
            l10n.totalRevenue,
            "0 FCFA", // Placeholder
            Icons.attach_money,
            const Color(0xFF10B981),
            const Color(0xFFECFDF5),
            width: cardWidth,
          ),
          SizedBox(
            width: isLargeScreen ? 16 : 0,
            height: isLargeScreen ? 0 : 16,
          ),
          _buildMetricCard(
            l10n.avgValue,
            "0 FCFA", // Placeholder
            Icons.shopping_bag_outlined,
            const Color(0xFFA855F7),
            const Color(0xFFF3E8FF),
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
    IconData icon,
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
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
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
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(AppLocalizations l10n, bool isLargeScreen) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            child: _buildChartCard(
              l10n.purchaseEvolution,
              LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == 0)
                            return const Text(
                              '2025-10-07',
                              style: TextStyle(fontSize: 10),
                            );
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: [const FlSpot(0, 1)],
                      isCurved: true,
                      color: const Color(0xFF10B981), // Green
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildChartCard(
              l10n.revenuePerPeriod,
              BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == 0)
                            return const Text(
                              '2025-10-07',
                              style: TextStyle(fontSize: 10),
                            );
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
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
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: Colors.grey.shade300,
                          width: 20,
                        ), // Placeholder data since revenue is 0
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon ?? Icons.bar_chart, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildHabitsGrid(AppLocalizations l10n, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isLargeScreen ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isLargeScreen ? 2.5 : 1.5,
          children: [
            _buildHabitCard(
              l10n.favoriteProducts,
              Icons.inventory_2_outlined,
              Colors.green,
              Column(children: [_buildFavoriteItem("Test", 1, l10n)]),
            ),
            _buildHabitCard(
              l10n.purchaseFrequency,
              Icons.access_time,
              Colors.blue,
              Center(
                child: Text(
                  l10n.newCustomer, // Placeholder logic
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
            _buildHabitCard(
              l10n.preferredHours,
              Icons.schedule,
              Colors.orange,
              Column(children: [_buildHourItem("17:00", 1, 1.0, l10n)]),
            ),
            _buildHabitCard(
              l10n.purchaseAmounts,
              Icons.attach_money,
              Colors.purple,
              _buildPurchaseAmountStats(l10n),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitCard(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(String name, int count, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7), // Light green
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "1",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$count achat",
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourItem(
    String time,
    int count,
    double percentage,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Grey bg
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5), // Light orange
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "1",
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$count achat", style: const TextStyle(fontSize: 12)),
              Text(
                "${(percentage * 100).toInt()}%",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseAmountStats(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(
              "0 FCFA",
              l10n.avg,
              const Color(0xFFA855F7),
            ), // Purple
            _buildStatItem("0 FCFA", l10n.min, Colors.grey),
            _buildStatItem("0 FCFA", l10n.max, Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        _buildProgressBar(l10n.smallPurchases, 0, Colors.grey),
        const SizedBox(height: 8),
        _buildProgressBar(
          l10n.mediumPurchases,
          1.0,
          const Color(0xFF10B981),
        ), // Green
        const SizedBox(height: 8),
        _buildProgressBar(l10n.largePurchases, 0, Colors.grey),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          flex: 7,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade100,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
