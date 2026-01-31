import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';

class ProductReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductReportDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    l10n.backToProductList,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product['category'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.active.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Stock: 2",
                          style: TextStyle(fontSize: 10),
                        ), // Mock
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = isLargeScreen
                    ? (constraints.maxWidth - 3 * 24) / 4
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _buildSummaryCard(
                      l10n.quantitySold,
                      "4",
                      Icons.grid_view,
                      Colors.blue,
                      width: cardWidth,
                    ),
                    _buildSummaryCard(
                      l10n.totalRevenue,
                      "2,800 FCFA",
                      Icons.download,
                      Colors.green,
                      width: cardWidth,
                    ),
                    _buildSummaryCard(
                      l10n.totalProfit,
                      "266.4 FCFA",
                      Icons.grid_view,
                      Colors.purple,
                      width: cardWidth,
                    ),
                    _buildSummaryCard(
                      l10n.profitMargin,
                      "9.5%",
                      Icons.grid_view,
                      Colors.orange,
                      width: cardWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Charts Row 1
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildChartContainer(
                    l10n.revenueDistribution,
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.red,
                              value: 70,
                              title: "Profit",
                              radius: 50,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              color: Colors.green,
                              value: 30,
                              title: "Cost",
                              radius: 50,
                              showTitle: false,
                            ),
                          ],
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    footer: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendDot(Colors.green, l10n.profit),
                        const SizedBox(width: 16),
                        _buildLegendDot(Colors.red, l10n.cost),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildChartContainer(
                    l10n.monthlySales,
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 2500,
                                  color: const Color(0xFF10B981),
                                  width: 100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 200,
                                  color: const Color(0xFF8B5CF6),
                                  width: 100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        "2023-12",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
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
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Charts Row 2
            _buildChartContainer(
              l10n.dailySalesTrend,
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 0),
                          const FlSpot(1, 0),
                          const FlSpot(2, 500), // Spike as per screenshot
                          const FlSpot(3, 0),
                          const FlSpot(4, 0),
                        ],
                        isCurved: false,
                        color: const Color(0xFF10B981),
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 0),
                          const FlSpot(1, 0),
                          const FlSpot(2, 100),
                          const FlSpot(3, 0),
                          const FlSpot(4, 0),
                        ],
                        isCurved: false,
                        color: const Color(0xFFEF4444), // Red line lower
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == 2) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "2023-12-01",
                                  style: TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox();
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
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Details
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.productDetails,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        l10n.purchasePrice,
                        product['purchasePrice'],
                        Colors.blue,
                      ),
                      _buildDetailItem(
                        "Marge unitaire",
                        "TODO",
                        Colors.purple,
                      ), // TODO localize
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        l10n.sellingPrice,
                        product['sellingPrice'],
                        Colors.green,
                      ),
                      _buildDetailItem(
                        "Marge en %",
                        "TODO",
                        Colors.orange,
                      ), // TODO localize
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        l10n.stock,
                        product['stock'].toString(),
                        Colors.red,
                      ),
                      _buildDetailItem(
                        "Valeur du stock",
                        "TODO",
                        Colors.black87,
                      ), // TODO localize
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart, {Widget? footer}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 24),
          chart,
          if (footer != null) ...[const SizedBox(height: 16), footer],
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
