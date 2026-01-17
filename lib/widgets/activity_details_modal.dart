import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';

import 'package:kioske/models/activity.dart';
import 'package:intl/intl.dart';

class ActivityDetailsModal extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsModal({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activityDetailsTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF7C3AED), // Purple
                  child: Text(
                    (activity.userName ?? 'User')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.userName ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Employee', // TODO: Fetch role if possible
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    l10n.type,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: activity.action == 'sale'
                            ? Colors.blue.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activity.action == 'sale'
                                ? Icons.shopping_cart
                                : Icons.login,
                            size: 14,
                            color: activity.action == 'sale'
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.action, // TODO: Localize action
                            style: TextStyle(
                              color: activity.action == 'sale'
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    l10n.date,
                    Text(
                      DateFormat('dd/MM/yyyy').format(activity.createdAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    l10n.time,
                    Text(
                      DateFormat('HH:mm').format(activity.createdAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    l10n.ipAddress,
                    const Text(
                      "::ffff:127.0.0.1", // Mock IP
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(l10n.description, activity.description ?? ''),
            const SizedBox(height: 16),
            if (activity.action == 'sale' && activity.metadata != null)
              _buildItemsTable(activity.metadata!, l10n)
            else
              _buildSection(
                l10n.details,
                activity.metadata ?? 'No additional details',
              ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label :",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildSection(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label :",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
      ],
    );
  }

  Widget _buildItemsTable(String metadata, AppLocalizations l10n) {
    try {
      // Strip "Items: " prefix if present
      String jsonStr = metadata;
      if (metadata.startsWith('Items: ')) {
        jsonStr = metadata.substring(7);
      }

      final List<dynamic> items = jsonDecode(jsonStr);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${l10n.details} :",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: [
                      _buildTableCell(l10n.productName, isHeader: true),
                      _buildTableCell(l10n.quantity, isHeader: true),
                      _buildTableCell(l10n.totalPrice, isHeader: true),
                    ],
                  ),
                  // Items
                  ...items.map((item) {
                    return TableRow(
                      children: [
                        _buildTableCell(item['product_name'] ?? 'N/A'),
                        _buildTableCell(item['quantity'].toString()),
                        _buildTableCell(
                          "${(item['unit_price'] * item['quantity']).toStringAsFixed(0)} FCFA",
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      // Fallback to simple text if parsing fails
      return _buildSection(l10n.details, metadata);
    }
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.grey.shade800 : Colors.black87,
        ),
      ),
    );
  }
}
