import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/providers/activity_provider.dart';
import 'package:kioske/widgets/activity_details_modal.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Filters - Placeholder for future implementation
  // final String _selectedEmployee = 'all';
  // final String _selectedType = 'all';
  // final DateTime? _startDate = DateTime.now().subtract(const Duration(days: 30));
  // final DateTime? _endDate = DateTime.now();
  // final String _activeQuickFilter = 'today';
  bool _isGridView =
      false; // TODO: Implement Grid View if needed, currently List

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activitiesTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.activitiesSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                // Grid/List toggle (visual only for now)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ToggleButtons(
                    isSelected: [!_isGridView, _isGridView],
                    onPressed: (index) {
                      setState(() {
                        _isGridView = index == 1;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey,
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFF10B981).withValues(alpha: 0.8),
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 36,
                    ),
                    children: [
                      Icon(
                        Icons.list,
                        size: 20,
                        color: !_isGridView ? Colors.white : Colors.grey,
                      ),
                      Icon(
                        Icons.grid_view,
                        size: 20,
                        color: _isGridView ? Colors.white : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters (Visual placeholder for now as per requirement focus on pagination)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      /*
                      Expanded(
                        child: _buildDropdown(
                          value: 'all', // _selectedEmployee,
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Tous les employés'),
                            ),
                          ],
                          onChanged: (val) {},
                          icon: Icons.person,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // More filters...
                      Expanded(
                        child: _buildDatePicker(
                          date: null, // _startDate,
                          onTap: () {},
                          placeholder: 'Date début',
                        ),
                      ),
                      */
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Activities List
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildHeaderCell('EMPLOYÉ'),
                              ),
                              Expanded(
                                flex: 4,
                                child: _buildHeaderCell('ACTIVITÉ'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildHeaderCell('DATE'),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildHeaderCell('HEURE'),
                              ),
                              const SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(
                                    'ACTIONS',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // List Items
                        if (provider.activities.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("Aucune activité trouvée"),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.activities.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final activity = provider.activities[index];
                              return _buildActivityRow(context, activity, l10n);
                            },
                          ),
                        // Pagination Controls
                        if (provider.totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: provider.currentPage > 1
                                      ? () => provider.loadActivities(
                                          page: provider.currentPage - 1,
                                        )
                                      : null,
                                ),
                                Text(
                                  'Page ${provider.currentPage} / ${provider.totalPages}',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed:
                                      provider.currentPage < provider.totalPages
                                      ? () => provider.loadActivities(
                                          page: provider.currentPage + 1,
                                        )
                                      : null,
                                ),
                              ],
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

  Widget _buildActivityRow(
    BuildContext context,
    Activity activity,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Employee
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 16,
                  child: Text(
                    (activity.userName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.userName ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Role placeholder (could be passed in metadata)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'User',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Activity
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(
                  activity.action == 'sale' ? Icons.shopping_cart : Icons.info,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.action.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description ?? activity.entityType,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(activity.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // Time
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(activity.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // Actions
          SizedBox(
            width: 60,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.visibility,
                  color: Colors.green,
                  size: 18,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ActivityDetailsModal(activity: activity),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }
}
