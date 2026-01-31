import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:kioske/providers/supply_delivery_provider.dart';
import 'package:kioske/models/supply_delivery.dart';
import 'package:kioske/widgets/new_delivery_modal.dart';
import 'package:kioske/widgets/confirm_delivery_modal.dart';
import 'package:kioske/widgets/delivery_details_modal.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  bool _isCardsView = true;
  // String _selectedFilter = 'all'; // Removed unused state for now

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplyDeliveryProvider>().loadDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // HUGE HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deliveryManagement,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B3C),
                      ),
                    ),
                    Text(
                      l10n.recentDeliveriesFirst,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const NewDeliveryModal(),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.newDelivery,
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
              ],
            ),
            const SizedBox(height: 24),

            // FILTER CARD
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
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: l10n.searchBySupplier,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          l10n.all,
                          2,
                          "all",
                          const Color(0xFF1A2B3C),
                          Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.completed,
                          0,
                          "completed",
                          const Color(0xFFE0F2F1),
                          Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.pending,
                          2,
                          "pending",
                          const Color(0xFFFFF8E1),
                          Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.cancelled,
                          0,
                          "cancelled",
                          const Color(0xFFFFEBEE),
                          Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "2 ${l10n.deliveriesFound}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GRID / TABLE CONTENT
            Expanded(
              child: Consumer<SupplyDeliveryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) {
                    return Center(child: Text('Error: ${provider.error}'));
                  }
                  if (provider.deliveries.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noDeliveriesFound ?? 'No deliveries found',
                      ),
                    );
                  }

                  final deliveries = provider.deliveries;

                  return _isCardsView
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width > 1200 ? 2 : 1;
                            final cardWidth =
                                (width - (crossAxisCount - 1) * 24) /
                                crossAxisCount;
                            double childAspectRatio =
                                cardWidth / 400; // Adjusted height
                            if (childAspectRatio > 1.6) childAspectRatio = 1.6;

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: childAspectRatio,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                              itemCount: deliveries.length,
                              itemBuilder: (context, index) =>
                                  _buildDeliveryCard(
                                    context,
                                    l10n,
                                    deliveries[index],
                                  ),
                            );
                          },
                        )
                      : _buildTableView(l10n, deliveries);
                },
              ),
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
    int count,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return InkWell(
      onTap: () {
        // TODO: Implement filtering logic
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    AppLocalizations l10n,
    SupplyDelivery delivery,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    Color statusColor;
    String statusText;

    switch (delivery.status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusText = l10n.completed;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusText = l10n.cancelled;
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFF59E0B);
        statusText = l10n.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                delivery.supplierName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(delivery.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                timeFormat.format(delivery.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          _buildDetailRow(
            l10n.totalAmount,
            currencyFormat.format(delivery.totalAmount),
            isBold: true,
            valueColor: Colors.green,
          ),
          _buildDetailRow(l10n.numberOfItems, "${delivery.itemCount}"),

          const SizedBox(height: 16),
          const Spacer(),

          // Actions
          Row(
            children: [
              if (delivery.status == 'pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ConfirmDeliveryModal(delivery: delivery),
                      );
                    },
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: Text(
                      l10n.confirmDelivery,
                      style: const TextStyle(color: Colors.green),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (delivery.status == 'pending') const SizedBox(width: 12),
              if (delivery.status == 'pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      context.read<SupplyDeliveryProvider>().cancelDelivery(
                        delivery.id,
                        currentUserId:
                            authProvider.currentUser?.id ?? 'unknown',
                        currentUserName: authProvider.currentUser?.name,
                      );
                    },
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: Text(
                      l10n.cancel,
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          DeliveryDetailsModal(delivery: delivery),
                    );
                  },
                  icon: const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.blue,
                  ),
                  label: Text(
                    l10n.seeMore,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (delivery.status != 'completed') const SizedBox(width: 12),
              if (delivery.status != 'completed')
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.delete),
                          content: Text(l10n.deleteDeliveryConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                final authProvider = context
                                    .read<AuthProvider>();
                                context
                                    .read<SupplyDeliveryProvider>()
                                    .deleteDelivery(
                                      delivery.id,
                                      currentUserId:
                                          authProvider.currentUser?.id ??
                                          'unknown',
                                      currentUserName:
                                          authProvider.currentUser?.name,
                                    );
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                l10n.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(
    AppLocalizations l10n,
    List<SupplyDelivery> deliveries,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderCell(l10n.vendor)),
                Expanded(flex: 2, child: _buildHeaderCell(l10n.deliveryDate)),
                Expanded(child: _buildHeaderCell(l10n.numberOfItems)),
                Expanded(child: _buildHeaderCell(l10n.totalAmount)),
                Expanded(child: _buildHeaderCell(l10n.status)),
                Expanded(
                  child: _buildHeaderCell(l10n.actions, alignRight: true),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Table Rows
          Expanded(
            child: ListView.separated(
              itemCount: deliveries.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final delivery = deliveries[index];

                Color statusColor;
                String statusText;
                switch (delivery.status.toLowerCase()) {
                  case 'completed':
                    statusColor = Colors.green;
                    statusText = l10n.completed;
                    break;
                  case 'cancelled':
                    statusColor = Colors.red;
                    statusText = l10n.cancelled;
                    break;
                  case 'pending':
                  default:
                    statusColor = Colors.amber.shade800;
                    statusText = l10n.pending;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      // Vendor
                      Expanded(
                        flex: 2,
                        child: Text(
                          delivery.supplierName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // Date & Time
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(delivery.createdAt),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            Text(
                              timeFormat.format(delivery.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Items
                      Expanded(
                        child: Text(
                          "${delivery.itemCount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // Amount
                      Expanded(
                        child: Text(
                          currencyFormat.format(delivery.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      // Status
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Confirm Action
                            if (delivery.status == 'pending')
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                tooltip: l10n.confirmDelivery,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ConfirmDeliveryModal(
                                      delivery: delivery,
                                    ),
                                  );
                                },
                              ),
                            // See Details Action
                            IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                              tooltip: l10n.seeMore,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DeliveryDetailsModal(delivery: delivery),
                                );
                              },
                            ),
                            // Delete Action
                            if (delivery.status != 'completed')
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                tooltip: l10n.delete,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n.delete),
                                      content: Text(l10n.deleteDeliveryConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final authProvider = context
                                                .read<AuthProvider>();
                                            context
                                                .read<SupplyDeliveryProvider>()
                                                .deleteDelivery(
                                                  delivery.id,
                                                  currentUserId:
                                                      authProvider
                                                          .currentUser
                                                          ?.id ??
                                                      'unknown',
                                                  currentUserName: authProvider
                                                      .currentUser
                                                      ?.name,
                                                );
                                            Navigator.pop(ctx);
                                          },
                                          child: Text(
                                            l10n.delete,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool alignRight = false}) {
    return Text(
      text.toUpperCase(),
      textAlign: alignRight ? TextAlign.end : TextAlign.start,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.5,
      ),
    );
  }
}
