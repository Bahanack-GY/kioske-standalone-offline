/// Expense model for expense tracking
class Expense {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String
  category; // 'utilities' | 'salaries' | 'supplies' | 'maintenance' | 'other'
  final String? receipt; // Path to receipt image
  final String status; // 'pending' | 'approved' | 'rejected'
  final String createdBy; // User ID
  final String? approvedBy; // User ID
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRecurring;
  final String? recurrenceInterval; // 'weekly', 'monthly', 'yearly'

  Expense({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    this.receipt,
    this.status = 'pending',
    required this.createdBy,
    this.approvedBy,
    required this.expenseDate,
    required this.createdAt,
    this.updatedAt,
    this.isRecurring = false,
    this.recurrenceInterval,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      receipt: map['receipt'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdBy: map['created_by'] as String,
      approvedBy: map['approved_by'] as String?,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isRecurring: map['is_recurring'] == 1,
      recurrenceInterval: map['recurrence_interval'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'receipt': receipt,
      'status': status,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_interval': recurrenceInterval,
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    String? receipt,
    String? status,
    String? createdBy,
    String? approvedBy,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurrenceInterval,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      receipt: receipt ?? this.receipt,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    );
  }
}
