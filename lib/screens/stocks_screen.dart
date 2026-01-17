import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/theme/app_theme.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/providers/stock_provider.dart';
import 'package:kioske/widgets/stock_analytics_modal.dart';
import 'package:kioske/widgets/stock_order_modal.dart';
import 'package:kioske/widgets/stock_edit_modal.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  bool _isCardsView = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(value)} FCFA';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFFC0FF3E);
      case 'medium':
        return const Color(0xFFFFCC80);
      case 'low':
        return const Color(0xFFFFCDD2);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'available':
        return Colors.black87;
      case 'medium':
        return Colors.black87;
      case 'low':
        return AppColors.textPink;
      default:
        return Colors.black87;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'available':
        return l10n.goodStock;
      case 'medium':
        return l10n.mediumStock;
      case 'low':
        return l10n.lowStock;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
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
                          l10n.stockManagement,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2B3C),
                          ),
                        ),
                        if (provider.isLoading)
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
                    // Toggle
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
                const SizedBox(height: 24),

                // Search & Filter Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => provider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: l10n.searchStockPlaceholder,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildFilterChip(
                            l10n.all,
                            provider.totalCount.toString(),
                            'all',
                            Colors.grey.shade100,
                            Colors.black87,
                            Colors.black87,
                            Colors.white,
                            provider,
                          ),
                          const SizedBox(width: 12),
                          _buildFilterChip(
                            l10n.goodStock,
                            provider.goodCount.toString(),
                            'good',
                            const Color(0xFFC0FF3E),
                            const Color(0xFF64DD17),
                            Colors.black87,
                            Colors.white,
                            provider,
                          ),
                          const SizedBox(width: 12),
                          _buildFilterChip(
                            l10n.mediumStock,
                            provider.mediumCount.toString(),
                            'medium',
                            const Color(0xFFFFCC80),
                            Colors.orange.shade800,
                            Colors.black87,
                            Colors.white,
                            provider,
                          ),
                          const SizedBox(width: 12),
                          _buildFilterChip(
                            l10n.lowStock,
                            provider.lowCount.toString(),
                            'low',
                            const Color(0xFFFFF9C4),
                            const Color(0xFFFBC02D),
                            Colors.black87,
                            Colors.white,
                            provider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${provider.products.length} ${l10n.productsFound}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _isCardsView
                      ? _buildCardsView(l10n, provider)
                      : _buildTableView(l10n, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardsView(AppLocalizations l10n, StockProvider provider) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400
            ? 3
            : (MediaQuery.of(context).size.width > 900 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return _buildProductCard(l10n, product, provider);
      },
    );
  }

  Widget _buildTableView(AppLocalizations l10n, StockProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 250 - 48,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              columns: [
                DataColumn(
                  label: Text(
                    l10n.products,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.currentStock,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.unitPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Actions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: provider.products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            provider.getCategoryName(product.categoryId),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text("${product.stock} ${l10n.pieces}")),
                    DataCell(Text(_formatCurrency(product.salePrice))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(product.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusLabel(product.status, l10n),
                          style: TextStyle(
                            color: _getStatusTextColor(product.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () => _showAnalytics(context, product),
                            tooltip: l10n.graph,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_note,
                              color: Colors.orange.shade800,
                            ),
                            onPressed: () =>
                                _showEdit(context, product, provider),
                            tooltip: l10n.edit,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.green,
                            ),
                            onPressed: () => _showOrder(context, product),
                            tooltip: l10n.order,
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
      ),
    );
  }

  void _showAnalytics(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) =>
          StockAnalyticsModal(productName: product.name, productId: product.id),
    );
  }

  void _showEdit(
    BuildContext context,
    Product product,
    StockProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => StockEditModal(
        product: {
          'id': product.id,
          'name': product.name,
          'category': provider.getCategoryName(product.categoryId),
          'categoryId': product.categoryId,
          'stock': product.stock.toString(),
          'purchasePrice': product.purchasePrice.toString(),
          'salePrice': product.salePrice.toString(),
        },
        onSave: (updatedData) async {
          final updatedProduct = product.copyWith(
            name: updatedData['name'],
            stock: int.tryParse(updatedData['stock'] ?? '') ?? product.stock,
            purchasePrice:
                double.tryParse(updatedData['purchasePrice'] ?? '') ??
                product.purchasePrice,
            salePrice:
                double.tryParse(updatedData['salePrice'] ?? '') ??
                product.salePrice,
          );
          await provider.updateProduct(updatedProduct);
        },
      ),
    );
  }

  void _showOrder(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => StockOrderModal(
        productName: product.name,
        currentPrice: _formatCurrency(product.salePrice),
      ),
    );
  }

  Widget _buildViewToggle(String label, IconData icon, bool isCard) {
    bool isSelected = _isCardsView == isCard;
    return InkWell(
      onTap: () => setState(() => _isCardsView = isCard),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected ? const Color(0xFFC0FF3E) : Colors.transparent,
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

  Widget _buildFilterChip(
    String label,
    String count,
    String filterKey,
    Color bgColor,
    Color selectedColor,
    Color textColor,
    Color selectedTextColor,
    StockProvider provider,
  ) {
    bool isSelected = provider.selectedFilter == filterKey;

    return InkWell(
      onTap: () => provider.setFilter(filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            color: isSelected ? selectedTextColor : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    AppLocalizations l10n,
    Product product,
    StockProvider provider,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        provider.getCategoryName(product.categoryId),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(product.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusLabel(product.status, l10n),
                    style: TextStyle(
                      color: _getStatusTextColor(product.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Data Table
            Column(
              children: [
                _buildDataRow(
                  "${l10n.currentStock}:",
                  "${product.stock} ${l10n.pieces}",
                ),
                const SizedBox(height: 4),
                _buildDataRow(
                  "${l10n.unitPrice}:",
                  _formatCurrency(product.salePrice),
                ),
              ],
            ),

            // Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    l10n.graph,
                    Icons.visibility,
                    const Color(0xFFE3F2FD),
                    Colors.blue,
                    () => _showAnalytics(context, product),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    l10n.edit,
                    Icons.edit_note,
                    const Color(0xFFFFF9C4),
                    Colors.orange.shade800,
                    () => _showEdit(context, product, provider),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    "+ ${l10n.order}",
                    null,
                    const Color(0xFFE0F2F1),
                    Colors.green,
                    () => _showOrder(context, product),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData? icon,
    Color bg,
    Color text,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
