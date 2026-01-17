import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/employee.dart';
import 'package:kioske/providers/employee_provider.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/widgets/new_employee_modal.dart';
import 'package:kioske/widgets/employee_analytics_modal.dart';
import 'package:kioske/widgets/edit_employee_modal.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool _isCardsView = true;
  String _selectedRole = "all"; // all, Cashier, Accountant, Co-proprietor
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<EmployeeProvider>();
    final employees = provider.employees;
    final isLoading = provider.isLoading;

    // Filtering logic
    List<Employee> filteredEmployees = employees;
    if (_selectedRole != 'all') {
      filteredEmployees = filteredEmployees
          .where((e) => e.role == _selectedRole)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredEmployees = filteredEmployees.where((e) {
        final query = _searchQuery.toLowerCase();
        return e.name.toLowerCase().contains(query) ||
            (e.email?.toLowerCase().contains(query) ?? false) ||
            (e.phone?.contains(query) ?? false);
      }).toList();
    }

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
                  l10n.employeesManagement,
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
                          builder: (context) => const NewEmployeeModal(),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.addEmployee,
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

            // Search & Filter Card
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: l10n.searchEmployeePlaceholder,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Role Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(l10n.all, employees.length, 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.cashiers,
                          employees.where((e) => e.role == 'Cashier').length,
                          'Cashier',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.accountants,
                          employees.where((e) => e.role == 'Accountant').length,
                          'Accountant',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          l10n.coproprietors,
                          employees
                              .where((e) => e.role == 'Co-proprietor')
                              .length,
                          'Co-proprietor',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.employeesFound(filteredEmployees.length),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _isCardsView
                    ? _buildCardsView(l10n, filteredEmployees)
                    : _buildTableView(l10n, filteredEmployees),
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

  Widget _buildFilterChip(
    String label,
    int count,
    String roleKey, {
    Color color = Colors.black87,
  }) {
    bool isSelected = _selectedRole == roleKey;
    return FilterChip(
      label: Text("$label ($count)"),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      backgroundColor: isSelected
          ? (roleKey == 'all' ? Colors.grey.shade800 : color)
          : (roleKey == 'all' ? Colors.grey.shade200 : color.withOpacity(0.1)),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (roleKey == 'all' ? Colors.black87 : color),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide.none,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildCardsView(AppLocalizations l10n, List<Employee> employees) {
    if (employees.isEmpty) {
      return Center(child: Text("No employees found"));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1300 ? 3 : (width > 900 ? 2 : 1);
        double childAspectRatio = 1.0;
        if (width > 1600)
          childAspectRatio = 1.4;
        else if (width > 1300)
          childAspectRatio = 1.2;
        else if (width > 900)
          childAspectRatio = 1.1; // adjust based on content

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: employees.length,
          itemBuilder: (context, index) =>
              _buildEmployeeCard(context, l10n, employees[index]),
        );
      },
    );
  }

  Widget _buildEmployeeCard(
    BuildContext context,
    AppLocalizations l10n,
    Employee employee,
  ) {
    String roleLabel = employee.role;
    if (employee.role == 'Cashier') roleLabel = l10n.cashiers;
    if (employee.role == 'Accountant') roleLabel = l10n.accountants;
    if (employee.role == 'Co-proprietor') roleLabel = l10n.coproprietors;

    if (roleLabel.endsWith('s'))
      roleLabel = roleLabel.substring(0, roleLabel.length - 1);

    // Gradient colors based on role? Or just generic blue-purple as in screenshot?
    // Screenshot shows same gradient for Co-proprietary (N) and Cashier (T, W). So generic.
    const gradient = LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFFA855F7)], // Blue to Purple
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    employee.name.isNotEmpty
                        ? employee.name.substring(0, 1).toUpperCase()
                        : "?",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleLabel, // Should be singular
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (employee.email != null)
                    Text(
                      employee.email!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  if (employee.phone != null)
                    Text(
                      employee.phone!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    l10n.salary,
                    "${employee.salary.toStringAsFixed(0)} FCFA",
                  ),
                  _buildInfoRow(
                    l10n.salary,
                    // Mock salary paid logic for now
                    "${employee.salary.toStringAsFixed(0)} FCFA",
                    isGreen: true,
                  ),
                  _buildInfoRow(
                    l10n.hireDate,
                    "${employee.hireDate.day}/${employee.hireDate.month}/${employee.hireDate.year}",
                  ),

                  const Spacer(),

                  // Actions
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
                                  EmployeeAnalyticsModal(employee: employee),
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
                          const Color(0xFFFFFBEB),
                          () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditEmployeeModal(employee: employee),
                            );
                          },
                        ), // Dark Yellow
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
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.delete),
                                content: Text(
                                  "Delete employee ${employee.name}?",
                                ),
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
                                          .read<EmployeeProvider>()
                                          .deleteEmployee(
                                            employee.id,
                                            currentUserId:
                                                authProvider.currentUser?.id ??
                                                'unknown',
                                            currentUserName:
                                                authProvider.currentUser?.name,
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
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? Colors.green : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
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
    Color bgColor, [
    VoidCallback? onPressed,
  ]) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 11),
      ), // Small font
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8), // Compact
        minimumSize: Size.zero,
      ),
    );
  }

  Widget _buildTableView(AppLocalizations l10n, List<Employee> employees) {
    if (employees.isEmpty) {
      return Center(child: Text("No employees found"));
    }
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
                      l10n.role,
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
                      l10n.phone,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.salary,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.hireDate,
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
                rows: employees.map((employee) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          employee.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(_buildRoleBadge(l10n, employee.role)),
                      DataCell(Text(employee.email ?? '')),
                      DataCell(Text(employee.phone ?? '')),
                      DataCell(
                        Text("${employee.salary.toStringAsFixed(0)} FCFA"),
                      ),
                      DataCell(
                        Text(
                          "${employee.hireDate.day}/${employee.hireDate.month}/${employee.hireDate.year}",
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
                                  builder: (context) => EmployeeAnalyticsModal(
                                    employee: employee,
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
                                      EditEmployeeModal(employee: employee),
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
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.delete),
                                    content: Text(
                                      "Delete employee ${employee.name}?",
                                    ),
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
                                              .read<EmployeeProvider>()
                                              .deleteEmployee(
                                                employee.id,
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
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
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

  Widget _buildRoleBadge(
    AppLocalizations l10n,
    String role, {
    bool isSmall = false,
  }) {
    String label = role;
    if (role == 'Cashier') label = l10n.cashiers;
    if (role == 'Accountant') label = l10n.accountants;
    if (role == 'Co-proprietor') label = l10n.coproprietors;

    if (label.endsWith('s')) label = label.substring(0, label.length - 1);

    Color color = Colors.blue;
    if (role == 'Accountant') color = Colors.green;
    if (role == 'Co-proprietor') color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
