import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';

import 'package:kioske/models/expense.dart';
import 'package:kioske/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:kioske/providers/auth_provider.dart';

class NewExpenseModal extends StatefulWidget {
  final Expense? expense;

  const NewExpenseModal({super.key, this.expense});

  @override
  State<NewExpenseModal> createState() => _NewExpenseModalState();
}

class _NewExpenseModalState extends State<NewExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  bool _isRecurring = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Loyer',
    'Électricité',
    'Eau',
    'Internet',
    'Salaire',
    'Maintenance',
    'Marketing',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );

    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.expenseDate;
      _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      );
      // _isRecurring = widget.expense!.isRecurring ?? false; // Unused for now or pending model update
    } else {
      _selectedCategory = 'Loyer'; // Default
      _selectedDate = DateTime.now();
      _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1), // Primary color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.expense != null;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? screenSize.width * 0.25 : 16,
        vertical: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? l10n.editExpenseTitle : l10n.addNewExpenseTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _titleController,
                              label: l10n.expenseTitle,
                              hint: "",
                              validator: (value) =>
                                  value!.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDropdown(l10n)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _amountController,
                              label:
                                  "${l10n.expenseAmount} (FCFA)", // Hardcoded FCFA as per screenshot
                              hint: "0",
                              keyboardType: TextInputType.number,
                              isNumber: true,
                              validator: (value) =>
                                  value!.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(context),
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  controller: _dateController,
                                  label: l10n.expenseDate,
                                  hint: "dd/mm/yyyy",
                                  suffixIcon: Icons.calendar_today,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _descriptionController,
                        label: l10n.expenseDescription,
                        hint: "",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _isRecurring,
                              onChanged: (value) {
                                setState(() {
                                  _isRecurring = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF6366F1),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.recurringExpenseLabel,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final provider = context.read<ExpenseProvider>();
                          try {
                            if (isEditing) {
                              await provider.updateExpense(
                                widget.expense!.copyWith(
                                  title: _titleController.text.trim(),
                                  amount: double.parse(
                                    _amountController.text.trim(),
                                  ),
                                  category: _selectedCategory!,
                                  description: _descriptionController.text
                                      .trim(),
                                  expenseDate: _selectedDate,
                                ),
                                currentUserId:
                                    context
                                        .read<AuthProvider>()
                                        .currentUser
                                        ?.id ??
                                    'unknown',
                                currentUserName: context
                                    .read<AuthProvider>()
                                    .currentUser
                                    ?.name,
                              );
                            } else {
                              await provider.addExpense(
                                title: _titleController.text.trim(),
                                amount: double.parse(
                                  _amountController.text.trim(),
                                ),
                                category: _selectedCategory ?? 'Loyer',
                                description: _descriptionController.text.trim(),
                                expenseDate: _selectedDate,
                                createdBy:
                                    context
                                        .read<AuthProvider>()
                                        .currentUser
                                        ?.id ??
                                    'unknown',
                                createdByName: context
                                    .read<AuthProvider>()
                                    .currentUser
                                    ?.name,
                              );
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1D5DB), // Light grey
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? l10n.save : l10n.addExpenseButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool isNumber = false,
    int maxLines = 1,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 20, color: Colors.grey.shade600)
                : (isNumber
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.unfold_more,
                            size: 20,
                            color: Colors.grey.shade400,
                          ), // Spinner-like
                        )
                      : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.expenseCategory,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
