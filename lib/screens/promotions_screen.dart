import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/promotion.dart';
import 'package:kioske/providers/promotion_provider.dart';
import 'package:kioske/widgets/new_promotion_modal.dart';
import 'package:provider/provider.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  bool _isTableView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().loadPromotions();
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
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 24),
          _buildSummaryCards(l10n, isLargeScreen),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  _buildFilterBar(l10n, context.watch<PromotionProvider>()),
                  const Divider(height: 1),
                  Expanded(
                    child: Consumer<PromotionProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _buildPromotionsContent(l10n, provider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.promotionsManagement,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const NewPromotionModal(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.createPromotion),
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
                fillColor: Colors.green.shade50,
                selectedColor: Colors.green,
                color: Colors.grey,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
                renderBorder: false,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.grid_view, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Cartes",
                        style: TextStyle(fontSize: 13),
                      ), // TODO: localize
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.table_chart, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Tableau",
                        style: TextStyle(fontSize: 13),
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

  Widget _buildSummaryCards(AppLocalizations l10n, bool isLargeScreen) {
    final provider = context.watch<PromotionProvider>();
    final allPromotions = provider.promotions;

    final activeCount = allPromotions.where((p) => p.isValid).length;
    final expiredCount = allPromotions
        .where((p) => DateTime.now().isAfter(p.endDate))
        .length;
    // Calculation: Sum of fixed amounts + (optional: estimate percentage value? usually tricky without orders)
    // For simplicity, just count promotions for now or sum fixed amounts
    final totalReductions = allPromotions
        .where((p) => p.type == 'fixed_amount')
        .fold(0.0, (sum, p) => sum + p.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = isLargeScreen
            ? (constraints.maxWidth - 3 * 24) / 4
            : constraints.maxWidth;

        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              l10n.totalPromotions,
              allPromotions.length.toString(),
              Colors.blue,
              Colors.blue.shade50,
              width: cardWidth,
              icon: Icons.card_giftcard,
            ),
            _buildSummaryCard(
              l10n.activePromotions,
              activeCount.toString(),
              Colors.green,
              Colors.green.shade50,
              width: cardWidth,
              icon: Icons.check_circle,
            ),
            _buildSummaryCard(
              l10n.expiredPromotions,
              expiredCount.toString(),
              Colors.red,
              Colors.red.shade50,
              width: cardWidth,
              icon: Icons.timer_off,
            ),
            _buildSummaryCard(
              l10n.totalReductions,
              "${NumberFormat('#,###').format(totalReductions)} FCFA",
              Colors.purple,
              Colors.purple.shade50,
              width: cardWidth,
              icon: Icons.percent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    Color bgColor, {
    double? width,
    IconData? icon,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n, PromotionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => provider.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: l10n.searchPromotionPlaceholder,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
          Wrap(
            spacing: 8,
            children: [
              _buildChip(
                "${l10n.allPromotions} (${provider.promotions.length})",
                Colors.black,
                provider.selectedStatus == 'Toutes',
                onTap: () => provider.setStatusFilter('Toutes'),
              ),
              _buildChip(
                "${l10n.active} (${provider.promotions.where((p) => p.isValid).length})",
                Colors.green.shade100,
                provider.selectedStatus == 'Active',
                textColor: Colors.green,
                onTap: () => provider.setStatusFilter('Active'),
              ),
              _buildChip(
                "${l10n.expired} (${provider.promotions.where((p) => DateTime.now().isAfter(p.endDate)).length})",
                Colors.red.shade100,
                provider.selectedStatus == 'Expired',
                textColor: Colors.red,
                onTap: () => provider.setStatusFilter('Expired'),
              ),
              _buildChip(
                "${l10n.inactive} (${provider.promotions.where((p) => !p.isActive).length})",
                Colors.orange.shade100,
                provider.selectedStatus == 'Inactive',
                textColor: Colors.orange,
                onTap: () => provider.setStatusFilter('Inactive'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                "Types: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              _buildTypeLink(l10n.allPromotions, 'Tous', provider),
              const SizedBox(width: 16),
              _buildTypeLink(l10n.percentage, 'percentage', provider),
              const SizedBox(width: 16),
              _buildTypeLink(l10n.fixedAmount, 'fixed_amount', provider),
              const SizedBox(width: 16),
              _buildTypeLink(l10n.buyXGetY, 'buy_x_get_y', provider),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.filteredPromotions.isEmpty)
            Text(
              l10n.noPromotionsFound,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    Color bgColor,
    bool isSelected, {
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeLink(
    String label,
    String value,
    PromotionProvider provider,
  ) {
    bool isSelected = provider.selectedType == value;
    bool isTous = value == 'Tous';

    return InkWell(
      onTap: () => provider.setTypeFilter(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: (isSelected || isTous)
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6) // Active Blue
              : (isTous ? const Color(0xFFF3F4F6) : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isTous ? const Color(0xFF374151) : const Color(0xFF3B82F6)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionsContent(
    AppLocalizations l10n,
    PromotionProvider provider,
  ) {
    final promotions = provider.filteredPromotions;

    if (promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Aucune promotion trouvée",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Implement List View (for simple verification, Grid View needs similar logic)
    // For now assuming _isTableView toggle maps to List vs Grid
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        final promo = promotions[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              promo.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "${promo.type} - Value: ${promo.value}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  "Valid: ${DateFormat('dd/MM/yyyy').format(promo.startDate)} - ${DateFormat('dd/MM/yyyy').format(promo.endDate)}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: promo.isActive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    promo.isActive ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: promo.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => NewPromotionModal(promotion: promo),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    // Confirm Delete
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                          'Voulez-vous vraiment supprimer cette promotion ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await context
                                  .read<PromotionProvider>()
                                  .deletePromotion(promo.id);
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
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
        );
      },
    );
  }
}
