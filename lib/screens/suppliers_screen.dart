import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/supplier_stats.dart';
import 'package:kioske/providers/supplier_provider.dart';
import 'package:kioske/widgets/new_supplier_modal.dart';
import 'package:kioske/widgets/edit_supplier_modal.dart';
import 'package:kioske/widgets/supplier_analytics_modal.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  bool _isCardsView = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().loadSuppliers();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supplierStats = context.watch<SupplierProvider>().supplierStats;

    // Filter Logic
    final filteredStats = supplierStats.where((stat) {
      final name = stat.supplier.name.toLowerCase();
      final phone = (stat.supplier.phone ?? "").toLowerCase();
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.suppliersManagement,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B3C),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const NewSupplierModal(),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.newSupplier,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Green
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // View Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _buildViewToggle(l10n.cards, Icons.grid_view, true),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade300,
                          ),
                          _buildViewToggle(l10n.table, Icons.table_rows, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Filter Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: l10n.searchSupplierPlaceholder,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    l10n.suppliersFound(filteredStats.length),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content Grid
            Expanded(
              child: _isCardsView
                  ? _buildCardsView(l10n, filteredStats)
                  : _buildTableView(l10n, filteredStats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(String label, IconData icon, bool isCard) {
    bool isSelected = _isCardsView == isCard;
    return InkWell(
      onTap: () => setState(() => _isCardsView = isCard),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? const Color(0xFFC0FF3E)
            : Colors.transparent, // Lime green highlight
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsView(AppLocalizations l10n, List<SupplierStats> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200 ? 2 : 1;
        // Aspect ratio for the card (adjust as needed for content height)
        // width / height
        double childAspectRatio = width > 1200 ? 1.6 : 1.8;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio:
                childAspectRatio /
                (crossAxisCount == 1 ? 0.7 : 1), // Tweak for single column
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) =>
              _buildSupplierCard(context, l10n, stats[index]),
        );
      },
    );
  }

  Widget _buildSupplierCard(
    BuildContext context,
    AppLocalizations l10n,
    SupplierStats stat,
  ) {
    final supplier = stat.supplier;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Phone, Address
          Text(
            supplier.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2B3C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supplier.phone ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            supplier.address ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Stats
          _buildStatRow(
            l10n.totalDeliveries,
            "${stat.totalDeliveries}",
            isBlue: true,
          ),
          _buildStatRow(
            l10n.amountReceived,
            "${stat.totalAmount.toStringAsFixed(0)} FCFA",
            isGreen: true,
          ),
          _buildStatRow(
            l10n.productsSupplied,
            "${stat.totalItemsSupplied}",
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Products List
          Text(
            "${l10n.productsSupplied}:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...(stat.productNames)
              .take(3)
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (stat.otherProductsCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                l10n.otherProducts(stat.otherProductsCount),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Spacer(),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SupplierAnalyticsModal(stats: stat),
                    );
                  },
                  icon: const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.blue,
                  ),
                  label: Text(
                    "Analytics", // TODO: localize
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          EditSupplierModal(supplier: supplier),
                    );
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFFA16207),
                  ), // Dark Yellow
                  label: Text(
                    l10n.edit,
                    style: const TextStyle(
                      color: Color(0xFFA16207),
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFBEB), // Pastel Yellow
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text("Delete supplier ${supplier.name}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<SupplierProvider>().deleteSupplier(
                                supplier.id,
                              );
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    bool isGreen = false,
    bool isBlue = false,
    bool isBold = false,
  }) {
    Color valueColor = Colors.black87;
    if (isGreen) valueColor = Colors.green;
    if (isBlue) valueColor = Colors.blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(AppLocalizations l10n, List<SupplierStats> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                dataRowColor: MaterialStateProperty.all(Colors.white),
                columnSpacing: 24,
                horizontalMargin: 24,
                columns: [
                  DataColumn(
                    label: Text(
                      l10n.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.whatsapp,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.neighborhood,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.deliveredProducts,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.actionsColumn,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: stats.map((stat) {
                  final supplier = stat.supplier;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          supplier.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(supplier.phone ?? '')),
                      DataCell(Text(supplier.address ?? '')),
                      DataCell(
                        Text(
                          "${stat.totalItemsSupplied} (Total: ${stat.totalDeliveries})",
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFA16207),
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      EditSupplierModal(supplier: supplier),
                                );
                              },
                              tooltip: l10n.edit,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                context.read<SupplierProvider>().deleteSupplier(
                                  supplier.id,
                                );
                              },
                              tooltip: l10n.delete,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
