import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/theme/app_theme.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:kioske/widgets/kioske_image.dart';
import 'package:kioske/widgets/product_analytics_modal.dart';
import 'package:kioske/widgets/stock_edit_modal.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isCardsView = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
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

    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProvider, categoryProvider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.productManagement,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2B3C),
                          ),
                        ),
                        if (productProvider.isLoading)
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
                    Row(
                      children: [
                        // Add Product Button
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddProduct(context, productProvider),
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            l10n.addProduct,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              _buildViewToggle(
                                l10n.cards,
                                Icons.grid_view,
                                true,
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey.shade300,
                              ),
                              _buildViewToggle(
                                l10n.table,
                                Icons.table_rows,
                                false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => productProvider.search(value),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: l10n.searchProductPlaceholder,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        l10n.all,
                        productProvider.products.length.toString(),
                        null,
                        productProvider.selectedCategoryId == null,
                        productProvider,
                      ),
                      const SizedBox(width: 12),
                      ...categoryProvider.categories.map((category) {
                        final count = categoryProvider.getProductCount(
                          category.id,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildCategoryChip(
                            category.name,
                            count.toString(),
                            category.id,
                            productProvider.selectedCategoryId == category.id,
                            productProvider,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${productProvider.filteredProducts.length} ${l10n.productsFound}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 16),

                // Content Grid/Table
                Expanded(
                  child: productProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productProvider.filteredProducts.isEmpty
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
                                l10n.noProductsFound,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _isCardsView
                      ? _buildGridView(l10n, productProvider, categoryProvider)
                      : _buildTableView(
                          l10n,
                          productProvider,
                          categoryProvider,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    String label,
    String count,
    String? categoryId,
    bool isSelected,
    ProductProvider productProvider,
  ) {
    return InkWell(
      onTap: () => productProvider.filterByCategory(categoryId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2B3C) : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(
    AppLocalizations l10n,
    ProductProvider productProvider,
    CategoryProvider categoryProvider,
  ) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400
            ? 3
            : (MediaQuery.of(context).size.width > 900 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: productProvider.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = productProvider.filteredProducts[index];
        return _buildProductCard(
          context,
          l10n,
          product,
          categoryProvider,
          productProvider,
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    AppLocalizations l10n,
    Product product,
    CategoryProvider categoryProvider,
    ProductProvider productProvider,
  ) {
    final category = categoryProvider.getCategoryById(product.categoryId);
    final categoryName = category?.name ?? l10n.unknown;
    final statusText = _getStatusLabel(product.status, l10n);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 12, right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(product.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: _getStatusTextColor(product.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Image (Box Icon)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: _buildProductImage(product.imageUrl),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      categoryName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Specs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildSpecRow(
                  "${l10n.purchasePrice}:",
                  _formatCurrency(product.purchasePrice),
                  false,
                ),
                const SizedBox(height: 8),
                _buildSpecRow(
                  "${l10n.salePrice}:",
                  _formatCurrency(product.salePrice),
                  true,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSpecRow(
                  "${l10n.margin}:",
                  _formatCurrency(product.margin),
                  true,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSpecRow(
                  "${l10n.currentStock}:",
                  "${product.stock} ${l10n.pieces}",
                  true,
                  Colors.black87,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  l10n.seeMore,
                  Icons.visibility,
                  const Color(0xFFE3F2FD),
                  Colors.blue,
                  () => _showAnalytics(context, product, categoryProvider),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  l10n.edit,
                  Icons.edit_note,
                  const Color(0xFFFFF9C4),
                  Colors.orange.shade800,
                  () => _showEdit(
                    context,
                    product,
                    categoryProvider,
                    productProvider,
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  l10n.delete,
                  Icons.delete,
                  const Color(0xFFFFEBEE),
                  Colors.red,
                  () => _confirmDelete(context, product, productProvider, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(
    String label,
    String value,
    bool isBold, [
    Color? color,
  ]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return KioskeImage(
      imageUrl: imageUrl,
      height: 64,
      width: 64,
      fit: BoxFit.contain,
      errorWidget: const Icon(Icons.inventory_2, size: 64, color: Colors.brown),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bg,
    Color text,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: text,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnalytics(
    BuildContext context,
    Product product,
    CategoryProvider categoryProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final category = categoryProvider.getCategoryById(product.categoryId);
    showDialog(
      context: context,
      builder: (context) => ProductAnalyticsModal(
        product: {
          'id': product.id,
          'name': product.name,
          'category': category?.name ?? l10n.unknown,
          'stock': product.stock.toString(),
          'purchasePrice': product.purchasePrice,
          'salePrice': product.salePrice,
        },
      ),
    );
  }

  void _showEdit(
    BuildContext context,
    Product product,
    CategoryProvider categoryProvider,
    ProductProvider productProvider,
  ) {
    final category = categoryProvider.getCategoryById(product.categoryId);
    showDialog(
      context: context,
      builder: (context) => StockEditModal(
        product: {
          'id': product.id,
          'name': product.name,
          'category': category?.name ?? '',
          'categoryId': product.categoryId,
          'stock': product.stock.toString(),
          'purchasePrice': product.purchasePrice.toString(),
          'salePrice': product.salePrice.toString(),
          'imageUrl': product.imageUrl,
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
            imageUrl: updatedData['imageUrl'],
          );
          final authProvider = context.read<AuthProvider>();
          await productProvider.updateProduct(
            updatedProduct,
            currentUserId: authProvider.currentUser?.id ?? 'unknown',
            currentUserName: authProvider.currentUser?.name,
          );
        },
      ),
    );
  }

  void _showAddProduct(BuildContext context, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => StockEditModal(
        product: const {
          'name': '',
          'category': '',
          'stock': '0',
          'purchasePrice': '0',
          'salePrice': '0',
          'imageUrl': null,
        },
        onSave: (data) async {
          await productProvider.addProduct(
            name: data['name'] ?? '',
            categoryId: data['categoryId'] ?? '',
            purchasePrice: double.tryParse(data['purchasePrice'] ?? '') ?? 0,
            salePrice: double.tryParse(data['salePrice'] ?? '') ?? 0,
            stock: int.tryParse(data['stock'] ?? '') ?? 0,
            imageUrl: data['imageUrl'],
            currentUserId:
                context.read<AuthProvider>().currentUser?.id ?? 'unknown',
            currentUserName: context.read<AuthProvider>().currentUser?.name,
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Product product,
    ProductProvider productProvider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteProductConfirm(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              productProvider.deleteProduct(
                product.id,
                currentUserId: authProvider.currentUser?.id ?? 'unknown',
                currentUserName: authProvider.currentUser?.name,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
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

  Widget _buildTableView(
    AppLocalizations l10n,
    ProductProvider productProvider,
    CategoryProvider categoryProvider,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
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
                    l10n.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.category,
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
                    l10n.purchasePrice,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.salePrice,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.margin,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    l10n.actions,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: productProvider.filteredProducts.map((product) {
                final category = categoryProvider.getCategoryById(
                  product.categoryId,
                );
                final categoryName = category?.name ?? 'Unknown';
                final statusText = _getStatusLabel(product.status, l10n);

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(categoryName)),
                    DataCell(Text("${product.stock}")),
                    DataCell(Text(_formatCurrency(product.purchasePrice))),
                    DataCell(
                      Text(
                        _formatCurrency(product.salePrice),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatCurrency(product.margin),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
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
                          statusText,
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
                            onPressed: () => _showAnalytics(
                              context,
                              product,
                              categoryProvider,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_note,
                              color: Colors.orange.shade800,
                            ),
                            onPressed: () => _showEdit(
                              context,
                              product,
                              categoryProvider,
                              productProvider,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(
                              context,
                              product,
                              productProvider,
                              l10n,
                            ),
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
}
