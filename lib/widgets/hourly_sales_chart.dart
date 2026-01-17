import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HourlySalesChart extends StatelessWidget {
  final Map<int, double> hourlySales;

  const HourlySalesChart({super.key, this.hourlySales = const {}});

  @override
  Widget build(BuildContext context) {
    // Find max value for Y axis scaling
    double maxY = 4;
    if (hourlySales.isNotEmpty) {
      final maxSale = hourlySales.values.fold<double>(
        0,
        (a, b) => a > b ? a : b,
      );
      maxY = maxSale > 0 ? maxSale * 1.2 : 4; // Add 20% padding
    }

    // Build spots from hourly sales data
    final spots = <FlSpot>[];
    for (int hour = 0; hour <= 24; hour++) {
      final sales = hourlySales[hour] ?? 0;
      spots.add(FlSpot(hour.toDouble(), sales));
    }

    // If no data, show flat line
    if (hourlySales.isEmpty) {
      spots.clear();
      spots.add(const FlSpot(0, 0));
      spots.add(const FlSpot(24, 0));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 4,
          verticalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Color(0xffe7e8ec),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
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
              interval: 2,
              getTitlesWidget: (value, meta) {
                if (value % 2 != 0) return const SizedBox.shrink();

                final int hour = value.toInt();
                final String text = '${hour.toString().padLeft(2, '0')}:00';

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xff7589a2),
                      fontWeight: FontWeight.bold,
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
              interval: maxY / 4,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                // Format large numbers
                String text;
                if (value >= 1000000) {
                  text = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  text = value.toStringAsFixed(0);
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xff7589a2),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xff37434d).withValues(alpha: 0.1),
          ),
        ),
        minX: 0,
        maxX: 24,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: hourlySales.isNotEmpty,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.blue,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final hour = spot.x.toInt();
                final value = spot.y;
                return LineTooltipItem(
                  '${hour.toString().padLeft(2, '0')}:00\n${_formatCurrency(value)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K FCFA';
    } else {
      return '${value.toStringAsFixed(0)} FCFA';
    }
  }
}
