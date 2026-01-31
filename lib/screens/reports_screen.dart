import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:kioske/providers/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:kioske/models/supply_delivery.dart';
// import 'package:kioske/screens/product_report_detail_screen.dart'; // TODO: Update detail screen if needed

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'products';
  bool _isTableView = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial report data if needed, or rely on FutureBuilder/Consumer in build
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 24),
          _buildReportTypeSelector(l10n),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText:
                  l10n.searchProductsPlaceholder, // Generic search placeholder
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onChanged: (val) {
              // Implement local search on displayed data if needed
            },
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildReportContent(l10n)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.reports,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final provider = context.read<ReportProvider>();
                  final path = await provider.exportToExcel(
                    _selectedReportType,
                    context,
                  );
                  if (mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.exportSuccess(path))),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.exportFailed(e.toString()))),
                    );
                  }
                }
              },
              icon: context.watch<ReportProvider>().isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download, size: 18),
              label: Text(l10n.exportExcel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ToggleButtons(
                isSelected: [!_isTableView, _isTableView],
                onPressed: (index) {
                  setState(() {
                    _isTableView = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                fillColor: const Color(
                  0xFFD4F59A,
                ), // Lime green from sidebar active
                selectedColor: const Color(0xFF1A2B3C),
                color: Colors.grey,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
                renderBorder: false,
                children: [
                  Row(
                    children: [
                      Icon(Icons.grid_view, size: 18),
                      SizedBox(width: 8),
                      Text(l10n.cards, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.table_chart, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.table,
                        style: const TextStyle(fontSize: 13),
                      ), // TODO: localize
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportType,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReportTypeCard(
                  l10n.productsReport,
                  Icons.inventory_2,
                  'products',
                  isActive: _selectedReportType == 'products',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.customersReport,
                  Icons.people,
                  'clients',
                  isActive: _selectedReportType == 'clients',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.dailySalesReport,
                  Icons.bar_chart,
                  'sales_daily',
                  isActive: _selectedReportType == 'sales_daily',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.hourlySalesReport,
                  Icons.access_time,
                  'sales_hourly',
                  isActive: _selectedReportType == 'sales_hourly',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.stockMovementsReport,
                  Icons.swap_horiz,
                  'stock_movements',
                  isActive: _selectedReportType == 'stock_movements',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.purchasesReport,
                  Icons.shopping_cart,
                  'purchases',
                  isActive: _selectedReportType == 'purchases',
                ),
                const SizedBox(width: 16),
                _buildReportTypeCard(
                  l10n.employeesReportTitle, // Localization needed
                  Icons.badge,
                  'employees',
                  isActive: _selectedReportType == 'employees',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard(
    String label,
    IconData icon,
    String typeId, {
    bool isActive = false,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedReportType = typeId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue.shade800 : Colors.blue,
              size: 28,
            ), // Icons seem to be generic blue/colored
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.blue.shade900 : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(AppLocalizations l10n) {
    // Determine which report to build
    switch (_selectedReportType) {
      case 'products':
        return FutureBuilder(
          future: context.read<ReportProvider>().getProductsReport(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(l10n.errorGeneric(snapshot.error.toString())),
              );
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return Center(child: Text(l10n.noProductsFound));
            }
            return _buildProductsGrid(l10n, products);
          },
        );
      case 'clients':
        return FutureBuilder(
          future: context.read<ReportProvider>().getCustomersReport(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(l10n.errorGeneric(snapshot.error.toString())),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n.noCustomersFound));
            }

            // For simplicity using a ListView for customers
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final c = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.phone ?? ''),
                    trailing: Text(l10n.ordersCount(c.orderCount)),
                  ),
                );
              },
            );
          },
        );
      case 'stock_movements':
        return FutureBuilder(
          future: context.read<ReportProvider>().getStockMovementsReport(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(l10n.errorGeneric(snapshot.error.toString())),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n.noMovementsFound));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final m = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text("${m.type} - ${l10n.quantity}: ${m.quantity}"),
                    subtitle: Text(
                      "Product ID: ${m.productId}\n${l10n.date}: ${DateFormat('yyyy-MM-dd HH:mm').format(m.createdAt)}",
                    ),
                    isThreeLine: true,
                    trailing: Text(m.reason ?? ''),
                  ),
                );
              },
            );
          },
        );
      case 'sales_daily':
        return _buildDailySalesReport(l10n);
      case 'sales_hourly':
        return _buildHourlySalesReport(l10n);
      case 'purchases':
        return _buildPurchasesReport(l10n);
      case 'employees':
        return _buildEmployeeReport(l10n);
      default:
        return Center(child: Text(l10n.comingSoon));
    }
  }

  Widget _buildProductsGrid(AppLocalizations l10n, List<dynamic> products) {
    // 3 cols on large screen
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1400 ? 3 : (screenWidth > 1000 ? 2 : 1);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductReportCard(l10n, product);
      },
    );
  }

  Widget _buildProductReportCard(
    AppLocalizations l10n,
    dynamic product, // Product model
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.categoryId, // Ideally map to category name
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataRow(
            l10n.purchasePrice,
            "${product.purchasePrice} FCFA",
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildDataRow(
            l10n.sellingPrice,
            "${product.salePrice} FCFA",
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildDataRow(
            l10n.stock,
            product.stock.toString(),
            product.stock < 5 ? Colors.red : Colors.green,
          ),
          const Spacer(),
          // 'View Details' removed for now or needs update to accept Product object
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- New Report Builders ---

  Widget _buildDailySalesReport(AppLocalizations l10n) {
    // Default to last 30 days
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));

    return FutureBuilder(
      future: context.read<ReportProvider>().getDailySalesReport(start, end),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(child: Text(l10n.noSalesData));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final dayData = data[index];
                  return Card(
                    child: ListTile(
                      title: Text(dayData['date'] as String),
                      trailing: Text(
                        "${dayData['total']} FCFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      subtitle: Text(l10n.ordersCount(dayData['count'])),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHourlySalesReport(AppLocalizations l10n) {
    // Default to today
    final date = DateTime.now();

    return FutureBuilder(
      future: context.read<ReportProvider>().getHourlySalesReport(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final data = snapshot.data ?? {};
        if (data.isEmpty) {
          return Center(child: Text(l10n.noSalesToday));
        }

        final maxSale = data.values.isEmpty
            ? 0.0
            : data.values.reduce((a, b) => a > b ? a : b);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                l10n.hourlySalesFor(DateFormat('yyyy-MM-dd').format(date)),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(24, (index) {
                    final amount = data[index] ?? 0.0;
                    final heightFactor = maxSale > 0 ? amount / maxSale : 0.0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (amount > 0)
                          Text(
                            amount.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 200 * heightFactor, // Max height 200
                          decoration: BoxDecoration(
                            color: amount > 0
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("$index", style: const TextStyle(fontSize: 10)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchasesReport(AppLocalizations l10n) {
    return FutureBuilder(
      future: context.read<ReportProvider>().getPurchasesReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final purchases = (snapshot.data as List<dynamic>?) ?? [];
        if (purchases.isEmpty) {
          return Center(child: Text(l10n.noPurchasesFound));
        }

        return ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final p = purchases[index] as SupplyDelivery;
            return Card(
              child: ListTile(
                title: Text("${l10n.supplier}: ${p.supplierName}"),
                subtitle: Text(
                  "${l10n.status}: ${p.status}\n${l10n.date}: ${DateFormat('yyyy-MM-dd').format(p.createdAt)}",
                ),
                isThreeLine: true,
                trailing: Text(
                  "${p.totalAmount} FCFA",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeReport(AppLocalizations l10n) {
    return FutureBuilder(
      future: context.read<ReportProvider>().getEmployeePerformanceReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(child: Text(l10n.noEmployeeData));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final emp = data[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(emp['name'].substring(0, 1)),
                  ),
                  title: Text(emp['name'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${l10n.role}: ${emp['role']}"),
                      if (emp['lastLogin'] != null)
                        Text(
                          "${l10n.lastLogin}: ${DateFormat('MM/dd HH:mm').format(emp['lastLogin'] as DateTime)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        Text(
                          l10n.neverLoggedIn,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${l10n.today}: ${emp['todaySales']} FCFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "${l10n.total}: ${emp['totalSales']} FCFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        l10n.ordersCount(emp['orderCount']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
