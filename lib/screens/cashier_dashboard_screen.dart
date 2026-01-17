import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/widgets/customer_selection_modal.dart';
import 'package:kioske/screens/customers_screen.dart';

import 'package:provider/provider.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:kioske/providers/order_provider.dart';
import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/customer_provider.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/widgets/kioske_image.dart';
import 'package:kioske/widgets/sale_success_dialog.dart';
import 'package:kioske/models/customer.dart';
import 'package:kioske/repositories/customer_repository.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedScreenIndex =
      0; // 0: POS, 1: Customers, 2: Calendar, 3: Settings

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
      // Listen for order errors
      context.read<OrderProvider>().addListener(_handleOrderError);
    });
  }

  @override
  void dispose() {
    // Remove listener when screen is disposed
    context.read<OrderProvider>().removeListener(_handleOrderError);
    super.dispose();
  }

  void _handleOrderError() {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage!),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      // Clear error so it doesn't show again on every change
      orderProvider.clearError();
    }
  }

  // ...

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // 1. Sidebar
          _buildSidebar(context),

          // 2. Main Content
          Expanded(
            child: _selectedScreenIndex == 0
                ? _buildPOSContent(l10n)
                : _selectedScreenIndex == 1
                ? const CustomersScreen(isCashierView: true)
                : Center(
                    child: Text('Coming Soon'),
                  ), // Placeholder for othersHome
          ),

          // 3. Order Panel (Only show on POS screen)
          if (_selectedScreenIndex == 0) _buildOrderPanel(l10n),
        ],
      ),
    );
  }

  Widget _buildPOSContent(AppLocalizations l10n) {
    return Column(
      children: [
        // Header
        _buildHeader(l10n),

        // Categories
        _buildCategoryList(),

        // Product Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.85, // Adjust for card height
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: context
                  .watch<ProductProvider>()
                  .filteredProducts
                  .length,
              itemBuilder: (context, index) {
                final product = context
                    .read<ProductProvider>()
                    .filteredProducts[index];
                return _buildProductCard(product, l10n);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ... (Rest of the file)

  // --- Sidebar ---
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 80,
      color: const Color(0xFFF9FAFB), // Matches background generally, or white
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981), // Green brand color
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 40),

          // Menu Items
          _buildSidebarItem(Icons.home, 0),
          _buildSidebarItem(Icons.person_outline, 1),

          const Spacer(),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, int index) {
    final isActive = _selectedScreenIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: IconButton(
        icon: Icon(icon, color: isActive ? Colors.white : Colors.grey),
        onPressed: () {
          setState(() {
            _selectedScreenIndex = index;
          });
        },
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(AppLocalizations l10n) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final productProvider = context.watch<ProductProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().toString().split(' ')[0], // Simple date
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B3C),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Good morning, ${currentUser?.name ?? 'User'}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${TimeOfDay.now().format(context)}',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'La cave de simbock (${productProvider.totalCount} items)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2B3C),
                ),
              ),
            ],
          ),
          // Search
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => productProvider.search(value),
              decoration: InputDecoration(
                hintText: l10n.searchHere,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(
                  Icons.help_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Categories ---
  Widget _buildCategoryList() {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categories = categoryProvider.categories;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final isSelected =
              productProvider.selectedCategoryId ==
              (isAll ? null : category?.id);

          return ActionChip(
            avatar: isSelected
                ? const Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.black87,
                  ), // Generic icon
            label: Text(
              isAll ? 'All' : category!.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            backgroundColor: isSelected
                ? const Color(0xFF10B981)
                : Colors.white,
            side: isSelected
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () {
              productProvider.filterByCategory(isAll ? null : category?.id);
            },
          );
        },
      ),
    );
  }

  // --- Product Card ---
  Widget _buildProductCard(Product product, AppLocalizations l10n) {
    Color statusColor;
    String statusText;

    switch (product.status) {
      case 'low':
        statusColor = const Color(0xFFFF5252); // Red/Pink
        statusText = 'Faible'; // Mock localization
        break;
      case 'available':
        statusColor = const Color(0xFF10B981); // Green
        statusText = 'Disponible';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Moyen';
    }

    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: isOutOfStock
          ? null
          : () => context.read<OrderProvider>().addToCart(product),
      child: Opacity(
        opacity: isOutOfStock ? 0.6 : 1.0,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOutOfStock ? Colors.grey.shade200 : Colors.grey.shade100,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: KioskeImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Area
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${product.salePrice} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.stock}: ${product.stock}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.5', // Mock rating
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isOutOfStock ? l10n.outOfStock : l10n.addToCart,
                          style: TextStyle(
                            color: isOutOfStock
                                ? Colors.grey.shade400
                                : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Order Panel ---
  Widget _buildOrderPanel(AppLocalizations l10n) {
    return Container(
      width: 350,
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.theOrder,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order Type Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Type',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => context.read<OrderProvider>().setOrderType(
                          'dine_in',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                context.watch<OrderProvider>().orderType ==
                                    'dine_in'
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.dineIn,
                            style: TextStyle(
                              color:
                                  context.watch<OrderProvider>().orderType ==
                                      'dine_in'
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.read<OrderProvider>().setOrderType(
                          'delivery',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                context.watch<OrderProvider>().orderType ==
                                    'delivery'
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.delivery,
                            style: TextStyle(
                              color:
                                  context.watch<OrderProvider>().orderType ==
                                      'delivery'
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cart Contents
          Expanded(
            child: context.watch<OrderProvider>().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noItemsInOrder,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addBeverages,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: context.watch<OrderProvider>().itemCount,
                    itemBuilder: (context, index) {
                      final item = context.watch<OrderProvider>().cart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.unitPrice} FCFA',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => context
                                      .read<OrderProvider>()
                                      .updateQuantity(index, -1),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Find product to get max stock
                                    final products = context
                                        .read<ProductProvider>()
                                        .products;
                                    final product = products.firstWhere(
                                      (p) => p.id == item.productId,
                                      orElse: () => throw Exception(
                                        'Product not found for cart item',
                                      ),
                                    );

                                    context
                                        .read<OrderProvider>()
                                        .updateQuantity(
                                          index,
                                          1,
                                          maxStock: product.stock,
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => context
                                      .read<OrderProvider>()
                                      .removeFromCart(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          if (!context.watch<OrderProvider>().isEmpty) ...[
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.items,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${context.watch<OrderProvider>().subtotal.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.discount,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '-${context.watch<OrderProvider>().discount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${context.watch<OrderProvider>().total.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payments
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          l10n.payments,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      final provider = context.watch<OrderProvider>();
                      final isCash = provider.paymentMethod == 'cash';
                      final isMobile = [
                        'om',
                        'momo',
                      ].contains(provider.paymentMethod);

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      provider.setPaymentMethod('cash'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCash
                                        ? const Color(0xFF10B981)
                                        : Colors.grey.shade100,
                                    foregroundColor: isCash
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.cash),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!isMobile) {
                                      provider.setPaymentMethod('om');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMobile
                                        ? const Color(0xFF10B981)
                                        : Colors.grey.shade100,
                                    foregroundColor: isMobile
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.mobilePayment),
                                ),
                              ),
                            ],
                          ),
                          if (isMobile) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        provider.setPaymentMethod('om'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          provider.paymentMethod == 'om'
                                          ? Colors.orange.withOpacity(0.1)
                                          : null,
                                      side: BorderSide(
                                        color: provider.paymentMethod == 'om'
                                            ? Colors.orange
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      foregroundColor: Colors.orange.shade800,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Orange Money',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        provider.setPaymentMethod('momo'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          provider.paymentMethod == 'momo'
                                          ? const Color(0xFFFFCC00).withOpacity(
                                              0.1,
                                            ) // MTN Yellow
                                          : null,
                                      side: BorderSide(
                                        color: provider.paymentMethod == 'momo'
                                            ? const Color(0xFFFFCC00)
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'MTN Momo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Customer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.customer,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FutureBuilder<Customer?>(
                        future:
                            context.watch<OrderProvider>().selectedCustomerId !=
                                null
                            ? CustomerRepository().getById(
                                context
                                    .watch<OrderProvider>()
                                    .selectedCustomerId!,
                              )
                            : Future.value(null),
                        builder: (context, snapshot) {
                          final customer = snapshot.data;
                          return Text(
                            customer != null
                                ? customer.name
                                : l10n.notAvailable,
                            style: TextStyle(
                              color: customer != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontWeight: customer != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        final orderProvider = context.watch<OrderProvider>();
                        final selectedId = orderProvider.selectedCustomerId;
                        String buttonText = l10n.addCustomer;

                        if (selectedId != null) {
                          final customer = context
                              .read<CustomerProvider>()
                              .getCustomerById(selectedId);
                          if (customer != null) {
                            buttonText = customer.name;
                          }
                        }

                        return ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => CustomerSelectionModal(
                                onCustomerSelected: (Customer? customer) {
                                  context.read<OrderProvider>().setCustomer(
                                    customer?.id,
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedId != null
                                ? const Color(0xFF10B981) // Green if selected
                                : const Color(0xFF6B7280), // Slate grey
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(buttonText),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final orderProvider = context.read<OrderProvider>();
                        final customerProvider = context
                            .read<CustomerProvider>();

                        // Get customer name before completing order (which might clear state)
                        String? customerName;
                        if (orderProvider.selectedCustomerId != null) {
                          final customer = customerProvider.getCustomerById(
                            orderProvider.selectedCustomerId!,
                          );
                          customerName = customer?.name;
                        }

                        final order = await orderProvider.completeOrder(
                          authProvider.currentUser?.id ?? 'unknown',
                          cashierName: authProvider.currentUser?.name,
                        );

                        if (order != null && context.mounted) {
                          // Refresh products to show updated stock
                          context.read<ProductProvider>().loadProducts();

                          // Show success dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => SaleSuccessDialog(
                              total: order.total,
                              orderId: order.id,
                              items: order.items,
                              customerName: customerName,
                              paymentMethod: order.paymentMethod,
                            ),
                          );
                        } else if (context.mounted &&
                            orderProvider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(orderProvider.errorMessage!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: context.watch<OrderProvider>().isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.pay,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
