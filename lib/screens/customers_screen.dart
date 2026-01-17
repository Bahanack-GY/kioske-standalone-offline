import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/widgets/customer_analytics_modal.dart';
import 'package:kioske/widgets/new_customer_modal.dart';
import 'package:provider/provider.dart';
import 'package:kioske/providers/customer_provider.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/models/customer.dart';

class CustomersScreen extends StatefulWidget {
  final bool isCashierView;

  const CustomersScreen({super.key, this.isCashierView = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _isGridView = true;
  String _searchQuery = "";
  String _selectedFilter = "Tous"; // "Tous", "Fidèles", "Nouveaux"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final provider = context.watch<CustomerProvider>();
    final customers = provider.customers;
    final isLoading = provider.isLoading;

    // Filter Logic
    List<Customer> filteredCustomers = customers.where((customer) {
      final matchesSearch =
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (customer.phone?.contains(_searchQuery) ?? false) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (customer.address?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      if (!matchesSearch) return false;

      if (_selectedFilter == "Fidèles" && customer.status != 'vip') {
        return false;
      }
      if (_selectedFilter == "Nouveaux" && customer.status != 'new') {
        return false;
      }

      return true;
    }).toList();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 24),
            _buildFilters(l10n, filteredCustomers.length),
            const SizedBox(height: 24),
            filteredCustomers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No customers found", // Fallback for missing l10n
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                : _isGridView
                ? _buildCardsView(l10n, filteredCustomers)
                : _buildTableView(l10n, filteredCustomers),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.customersManagement,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const NewCustomerModal(),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n.addCustomer,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewToggleOption(Icons.grid_view, true),
                  _buildViewToggleOption(Icons.table_chart, false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggleOption(IconData icon, bool isGrid) {
    final isSelected = _isGridView == isGrid;
    return InkWell(
      onTap: () => setState(() => _isGridView = isGrid),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4F59A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n, int count) {
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
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: l10n.searchCustomerPlaceholder,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFilterChip(
                "Tous ($count)",
                "Tous",
                Colors.black,
                Colors.white,
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                "${l10n.loyal} (0)",
                "Fidèles",
                const Color(0xFF10B981),
                const Color(0xFFD1FAE5),
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                "${l10n.newCustomer} (0)",
                "Nouveaux",
                const Color(0xFFF97316),
                const Color(0xFFFFEDD5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.customersFound(count),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    Color textColor,
    Color bgColor,
  ) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsView(AppLocalizations l10n, List<Customer> customers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid logic
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8, // Adjust aspect ratio for card height
          ),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            return _buildCustomerCard(l10n, customers[index]);
          },
        );
      },
    );
  }

  Widget _buildCustomerCard(AppLocalizations l10n, Customer customer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient Header
          Container(
            height: 140, // Adjust height as per screenshot
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFFA855F7),
                ], // Blue to Purple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer.status, // Using status directly
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildIconText(Icons.phone, customer.phone ?? ''),
                  const SizedBox(height: 4),
                  _buildIconText(Icons.location_on, customer.address ?? ''),
                  const SizedBox(height: 4),
                  _buildIconText(Icons.email, customer.email ?? ''),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${l10n.totalPurchases}:",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "${customer.totalPurchases.toStringAsFixed(0)} FCFA",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981), // Green
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${l10n.memberSince}:",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        customer.createdAt.toString().split(
                          ' ',
                        )[0], // Simple date formatting
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Actions
                  Row(
                    children: [
                      if (!widget.isCashierView) ...[
                        Expanded(
                          child: _buildActionButton(
                            l10n.seeMore,
                            Icons.visibility,
                            Colors.blue,
                            Colors.blue.shade50,
                            () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    CustomerAnalyticsModal(customer: customer),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _buildActionButton(
                          l10n.edit,
                          Icons.edit,
                          const Color(0xFFA16207), // Dark yellow
                          const Color(0xFFFEF9C3), // Light yellow
                          () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  NewCustomerModal(customer: customer),
                            );
                          },
                        ),
                      ),
                      if (!widget.isCashierView) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            l10n.delete,
                            Icons.delete,
                            Colors.red,
                            Colors.red.shade50,
                            () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Customer'),
                                  content: Text(
                                    'Are you sure you want to delete this customer?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final authProvider = context
                                            .read<AuthProvider>();
                                        await context
                                            .read<CustomerProvider>()
                                            .deleteCustomer(
                                              customer.id,
                                              currentUserId:
                                                  authProvider
                                                      .currentUser
                                                      ?.id ??
                                                  'unknown',
                                              currentUserName: authProvider
                                                  .currentUser
                                                  ?.name,
                                            );
                                        if (context.mounted)
                                          Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text(l10n.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    Color bgColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(AppLocalizations l10n, List<Customer> customers) {
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
                      l10n.phone,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.email,
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
                      l10n.totalPurchases,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.memberSince,
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
                rows: customers.map((customer) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(customer.phone ?? '')),
                      DataCell(Text(customer.email ?? '')),
                      DataCell(Text(customer.address ?? '')),
                      DataCell(Text("${customer.totalPurchases}")),
                      DataCell(
                        Text(customer.createdAt.toString().split(' ')[0]),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!widget.isCashierView)
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        CustomerAnalyticsModal(
                                          customer: customer,
                                        ),
                                  );
                                },
                                tooltip: l10n.seeMore,
                              ),
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
                                      NewCustomerModal(customer: customer),
                                );
                              },
                              tooltip: l10n.edit,
                            ),
                            if (!widget.isCashierView)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Customer'),
                                      content: Text('Are you sure?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final authProvider = context
                                                .read<AuthProvider>();
                                            await context
                                                .read<CustomerProvider>()
                                                .deleteCustomer(
                                                  customer.id,
                                                  currentUserId:
                                                      authProvider
                                                          .currentUser
                                                          ?.id ??
                                                      'unknown',
                                                  currentUserName: authProvider
                                                      .currentUser
                                                      ?.name,
                                                );
                                            if (context.mounted)
                                              Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: Text(l10n.delete),
                                        ),
                                      ],
                                    ),
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
