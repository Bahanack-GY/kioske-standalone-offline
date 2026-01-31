import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/theme/app_theme.dart';
import 'package:kioske/widgets/dashboard_card.dart';
import 'package:kioske/widgets/hourly_sales_chart.dart';
import 'package:kioske/widgets/sidebar.dart';
import 'package:kioske/providers/dashboard_provider.dart';
import 'package:kioske/screens/stocks_screen.dart';
import 'package:kioske/screens/products_screen.dart';
import 'package:kioske/screens/deliveries_screen.dart';
import 'package:kioske/screens/suppliers_screen.dart';
import 'package:kioske/screens/employees_screen.dart';
import 'package:kioske/screens/customers_screen.dart';
import 'package:kioske/screens/expenses_screen.dart';
import 'package:kioske/screens/promotions_screen.dart';
import 'package:kioske/screens/reports_screen.dart';
import 'package:kioske/screens/activities_screen.dart';
import 'package:kioske/screens/settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final provider = context.read<DashboardProvider>();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: provider.selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
              primary: AppColors.textBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildDashboardContent(context, l10n)
                : _selectedIndex == 1
                ? const StocksScreen()
                : _selectedIndex == 2
                ? const ProductsScreen()
                : _selectedIndex == 3
                ? const DeliveriesScreen()
                : _selectedIndex == 4
                ? const SuppliersScreen()
                : _selectedIndex == 5
                ? const EmployeesScreen()
                : _selectedIndex == 6
                ? const CustomersScreen()
                : _selectedIndex == 7
                ? const ExpensesScreen()
                : _selectedIndex == 8
                ? const PromotionsScreen()
                : _selectedIndex == 9
                ? const ReportsScreen()
                : _selectedIndex == 10
                ? const ActivitiesScreen()
                : _selectedIndex == 11
                ? const SettingsScreen()
                : Center(child: Text(l10n.pageNotImplemented(_selectedIndex))),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AppLocalizations l10n) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildHeader(context, l10n, provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStatsGrid(context, l10n, provider),
                          const SizedBox(height: 24),
                          _buildChartsSection(context, l10n, provider),
                          const SizedBox(height: 24),
                          _buildListsSection(context, l10n, provider),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    DashboardProvider provider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final selectedRange = provider.selectedDateRange;
    final start = dateFormat.format(
      selectedRange.start.copyWith(hour: 0, minute: 0),
    );
    final end = dateFormat.format(
      selectedRange.end.copyWith(hour: 23, minute: 59),
    );
    final dateRangeText = "$start - $end";

    final duration = selectedRange.duration.inDays;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BackButton(),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _pickDateRange(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${l10n.period}: ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateRangeText,
                        style: const TextStyle(
                          color: AppColors.textBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textBlue,
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(l10n.reset, false, provider),
                _buildChip(l10n.today, duration == 0, provider),
                _buildChip(
                  l10n.last7Days,
                  duration == 6,
                  provider,
                  isGreen: true,
                ),
                _buildChip(
                  l10n.last30Days,
                  duration == 29,
                  provider,
                  isPurple: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool isActive,
    DashboardProvider provider, {
    bool isGreen = false,
    bool isPurple = false,
  }) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.black54;

    if (isActive) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue;
    } else if (isGreen) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
    } else if (isPurple) {
      bgColor = Colors.purple.shade50;
      textColor = Colors.purple;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        backgroundColor: bgColor,
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          final l10n = AppLocalizations.of(context)!;
          if (label == l10n.today) {
            provider.setToday();
          } else if (label == l10n.last7Days) {
            provider.setLast7Days();
          } else if (label == l10n.last30Days) {
            provider.setLast30Days();
          } else {
            provider.setToday();
          }
        },
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(value)} F CFA';
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AppLocalizations l10n,
    DashboardProvider provider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1300 ? 4 : (screenWidth > 900 ? 2 : 1);

    final cards = [
      // Row 1
      DashboardCard(
        title: l10n.totalSales,
        value: _formatCurrency(provider.totalSales),
        subtitle: l10n.fromSelectedPeriod,
        backgroundColor: AppColors.pastelGreen,
        textColor: AppColors.textGreen,
      ),
      DashboardCard(
        title: l10n.totalTransactions,
        value: provider.transactionCount.toString(),
        subtitle: l10n.fromSelectedPeriod,
        backgroundColor: AppColors.pastelOrange,
        textColor: AppColors.textOrange,
      ),
      DashboardCard(
        title: l10n.averageTransaction,
        value: _formatCurrency(provider.averageTransaction),
        subtitle: l10n.perTransaction,
        backgroundColor: AppColors.pastelPurple,
        textColor: AppColors.textPurple,
      ),
      DashboardCard(
        title: l10n.cashRegister,
        value: _formatCurrency(provider.netProfit),
        subtitle: l10n.availableBalance,
        backgroundColor: AppColors.pastelYellow,
        textColor: AppColors.textYellow,
        icon: Icons.money,
      ),
      // Row 2
      DashboardCard(
        title: l10n.mobileMoney,
        value: _formatCurrency(provider.mobileMoneySales),
        subtitle: l10n.mobilePayments,
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        icon: Icons.smartphone,
        iconColor: Colors.blue,
      ),
      DashboardCard(
        title: l10n.grossMargin,
        value: "${provider.grossMargin.toStringAsFixed(1)}%",
        subtitle: l10n.fromSelectedPeriod,
        backgroundColor: AppColors.pastelBlue,
        textColor: AppColors.textBlue,
      ),
      DashboardCard(
        title: l10n.netProfit,
        value: _formatCurrency(provider.netProfit),
        subtitle: l10n.fromSelectedPeriod,
        backgroundColor: AppColors.pastelPink,
        textColor: AppColors.textPink,
      ),
      DashboardCard(
        title: l10n.totalExpenses,
        value: _formatCurrency(provider.totalExpenses),
        subtitle: "",
        backgroundColor: Colors.white,
        textColor: AppColors.textRed,
        icon: Icons.money_off,
        iconColor: AppColors.textRed,
      ),
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: cards,
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    AppLocalizations l10n,
    DashboardProvider provider,
  ) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.hourlySales,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: HourlySalesChart(
                        hourlySales: provider.hourlySales,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.customers,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            _buildLegendItem(l10n.newCustomers, Colors.purple),
                            const SizedBox(width: 8),
                            _buildLegendItem(
                              l10n.returningCustomers,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCustomerStat(
                            l10n.newCustomers,
                            provider.newCustomerCount,
                            Colors.purple,
                          ),
                          _buildCustomerStat(
                            l10n.returningCustomers,
                            provider.returningCustomerCount,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerStat(String label, int count, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildListsSection(
    BuildContext context,
    AppLocalizations l10n,
    DashboardProvider provider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.top10BestSellers,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.topSellingProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          l10n.noSalesInPeriod,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...provider.topSellingProducts.map(
                      (product) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.productName),
                        subtitle: Text(l10n.soldCount(product.quantitySold)),
                        trailing: Text(
                          _formatCurrency(product.totalRevenue),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGreen,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.slowestSellingProducts,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.slowestSellingProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          l10n.noSalesInPeriod,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...provider.slowestSellingProducts.map(
                      (product) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.productName),
                        subtitle: Text(l10n.soldCount(product.quantitySold)),
                        trailing: Text(
                          _formatCurrency(product.totalRevenue),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOrange,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
