import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/expense.dart';
import 'package:kioske/providers/expense_provider.dart';
import 'package:kioske/widgets/expense_analytics_modal.dart';
import 'package:kioske/widgets/new_expense_modal.dart';
import 'package:provider/provider.dart';
import 'package:kioske/providers/auth_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _isGridView = true;
  String _searchQuery = "";
  String _selectedFilter = "all"; // "all", "approved", "pending", "overdue"
  String _selectedCategory = "Toutes";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.expenses;
    final isLoading = provider.isLoading;

    // Filter Logic
    List<Expense> filteredExpenses = expenses.where((expense) {
      final matchesSearch =
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      if (!matchesSearch) return false;

      // Status mapping: provider statuses are 'pending', 'approved', 'rejected'
      if (_selectedFilter == "approved" && expense.status != 'approved') {
        return false;
      }
      if (_selectedFilter == "pending" && expense.status != 'pending') {
        return false;
      }
      if (_selectedFilter == "overdue" && expense.status != 'overdue') {
        return false;
      }

      if (_selectedCategory != "Toutes" &&
          expense.category != _selectedCategory) {
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
            _buildSummaryCards(
              l10n,
              expenses,
            ), // Passing all expenses for summary
            const SizedBox(height: 24),
            _buildFilters(l10n, filteredExpenses.length),
            const SizedBox(height: 24),
            filteredExpenses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        l10n.noExpensesFound,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                : _isGridView
                ? _buildCardsView(l10n, filteredExpenses)
                : _buildTableView(l10n, filteredExpenses),
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
          l10n.expensesManagement,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const NewExpenseModal(),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n.addExpense,
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
                  _buildViewToggleOption(Icons.grid_view, l10n.cards, true),
                  _buildViewToggleOption(Icons.table_chart, l10n.table, false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggleOption(IconData icon, String label, bool isGrid) {
    final isSelected = _isGridView == isGrid;
    return InkWell(
      onTap: () => setState(() => _isGridView = isGrid),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4F59A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 18,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, List<Expense> expenses) {
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final paidExpenses = expenses
        .where((e) => e.status == 'approved')
        .fold(0.0, (sum, e) => sum + e.amount);
    final pendingExpenses = expenses
        .where((e) => e.status == 'pending')
        .fold(0.0, (sum, e) => sum + e.amount);
    final overdueExpenses = 0.0; // TODO: Implement overdue logic

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            l10n.totalExpenses,
            "${NumberFormat('#,###').format(totalExpenses)} FCFA",
            Colors.blue.shade50,
            Colors.blue,
            Icons.money_off,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            l10n.paidExpenses,
            "${NumberFormat('#,###').format(paidExpenses)} FCFA",
            Colors.green.shade50,
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            l10n.pendingExpenses,
            "${NumberFormat('#,###').format(pendingExpenses)} FCFA",
            Colors.orange.shade50,
            Colors.orange,
            Icons.access_time,
            isWarning: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            l10n.overdueExpenses,
            "${NumberFormat('#,###').format(overdueExpenses)} FCFA",
            Colors.red.shade50,
            Colors.red,
            Icons.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color bgColor,
    Color iconColor,
    IconData icon, {
    bool isWarning = false,
  }) {
    return Container(
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.orange : Colors.black,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
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
              hintText: l10n.searchExpensesPlaceholder,
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
                "${l10n.all} ($count)",
                "all",
                Colors.black,
                Colors.white,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                "${l10n.paid} (0)", // Dynamic count logic not implemented in original
                "approved",
                Colors.green,
                Colors.green.shade50,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                "${l10n.pending} (6)", // Dynamic count logic not implemented in original
                "pending",
                Colors.orange,
                Colors.orange.shade50,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                "${l10n.overdue} (0)", // Dynamic count logic not implemented in original
                "overdue",
                Colors.red,
                Colors.red.shade50,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "Catégories: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                _buildCategoryChip("Toutes"),
                _buildCategoryChip("Loyer", color: Colors.red),
                _buildCategoryChip("Électricité", color: Colors.orange),
                _buildCategoryChip("Eau", color: Colors.blue),
                _buildCategoryChip("Internet", color: Colors.purple),
                _buildCategoryChip("Salaire", color: Colors.green),
                _buildCategoryChip("Maintenance", color: Colors.brown),
                _buildCategoryChip("Marketing", color: Colors.pink),
                _buildCategoryChip("Autres", color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$count charge(s)", // Simple for now
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
          borderRadius: BorderRadius.circular(8),
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

  Widget _buildCategoryChip(String label, {Color? color}) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (color ?? Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsView(AppLocalizations l10n, List<Expense> expenses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 800)
          crossAxisCount = 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            return _buildExpenseCard(l10n, expenses[index]);
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(AppLocalizations l10n, Expense expense) {
    Color statusColor = Colors.orange;
    Color statusBg = Colors.orange.shade50;
    String statusText = l10n.pending;

    if (expense.status == 'approved') {
      statusColor = Colors.green;
      statusBg = Colors.green.shade50;
      statusText = l10n.paid;
    } else if (expense.status == 'rejected') {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
      statusText = l10n.rejected;
    } else if (expense.status == 'overdue') {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
      statusText = l10n.overdue;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                expense.category,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 8),
              // Recurring logic removed or needs implementing in model
              /*
              if (expense.isRecurring == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Récurrent",
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ),
                */
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expense.description ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${l10n.expenseAmount}:",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "${NumberFormat('#,###').format(expense.amount)} FCFA",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${l10n.expenseDate}:",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(expense.expenseDate),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                          ExpenseAnalyticsModal(expense: expense),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  l10n.edit,
                  Icons.edit,
                  const Color(0xFFA16207),
                  const Color(0xFFFEF9C3),
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => NewExpenseModal(expense: expense),
                    );
                  },
                ),
              ),
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
                        title: Text(l10n.deleteExpense),
                        content: Text(l10n.deleteExpenseConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              final authProvider = context.read<AuthProvider>();
                              await context
                                  .read<ExpenseProvider>()
                                  .deleteExpense(
                                    expense.id,
                                    currentUserId:
                                        authProvider.currentUser?.id ??
                                        'unknown',
                                    currentUserName:
                                        authProvider.currentUser?.name,
                                  );
                              if (context.mounted) Navigator.pop(context);
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
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l10n.markAsPaid),
            ),
          ),
        ],
      ),
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

  Widget _buildTableView(AppLocalizations l10n, List<Expense> expenses) {
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
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                dataRowColor: WidgetStateProperty.all(Colors.white),
                columnSpacing: 24,
                horizontalMargin: 24,
                columns: [
                  DataColumn(
                    label: Text(
                      l10n.expenseTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.expenseCategory,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.expenseAmount,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.expenseDate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.expenseStatus,
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
                rows: expenses.map((expense) {
                  // Status logic for table
                  Color statusColor = Colors.orange;
                  Color statusBg = Colors.orange.shade50;
                  String statusText = l10n.pending;

                  if (expense.status == 'approved') {
                    statusColor = Colors.green;
                    statusBg = Colors.green.shade50;
                    statusText = l10n.paid;
                  } else if (expense.status == 'rejected') {
                    statusColor = Colors.red;
                    statusBg = Colors.red.shade50;
                    statusText = 'Rejected';
                  } else if (expense.status == 'overdue') {
                    statusColor = Colors.red;
                    statusBg = Colors.red.shade50;
                    statusText = l10n.overdue;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(expense.category)),
                      DataCell(
                        Text(
                          "${NumberFormat('#,###').format(expense.amount)} FCFA",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          DateFormat('dd/MM/yyyy').format(expense.expenseDate),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
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
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ExpenseAnalyticsModal(expense: expense),
                                );
                              },
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
                                      NewExpenseModal(expense: expense),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {},
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
