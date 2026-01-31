import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/providers/settings_provider.dart';
import 'package:kioske/repositories/employee_repository.dart';
import 'package:kioske/models/employee.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isExpanded = true;
  final EmployeeRepository _employeeRepository = EmployeeRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>().settings;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExpanded ? 250 : 80,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo & Toggle Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isExpanded) ...[
                  // Expanded Logo
                  if (settings.businessLogo != null &&
                      settings.businessLogo!.isNotEmpty &&
                      File(settings.businessLogo!).existsSync())
                    Image.file(
                      File(settings.businessLogo!),
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  else
                    Image.asset('assets/images/Logo-3.png', height: 40),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      settings.businessName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20, // Slightly smaller to fit dynamic names
                        fontWeight: FontWeight.bold,
                        color: Color(
                          0xFF1A2B3C,
                        ), // Dark blue/black color from image
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                ] else
                // Collapsed Logo (Icon only) - Usually just the logo
                if (settings.businessLogo != null &&
                    settings.businessLogo!.isNotEmpty &&
                    File(settings.businessLogo!).existsSync())
                  Image.file(
                    File(settings.businessLogo!),
                    height: 40,
                    fit: BoxFit.contain,
                  )
                else
                  Image.asset('assets/images/Logo-3.png', height: 40),

                if (_isExpanded)
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.chevron_left, size: 20),
                    ),
                  ),
              ],
            ),
          ),

          if (!_isExpanded) ...[
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _isExpanded = true),
            ),
          ],

          const SizedBox(height: 32),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  0,
                  Icons.dashboard,
                  l10n.dashboard,
                  isGreen: true,
                ),
                _buildMenuItem(1, Icons.inventory_2, l10n.stocks),
                _buildMenuItem(2, Icons.layers, l10n.products),
                _buildMenuItem(3, Icons.local_shipping, l10n.deliveries),
                _buildMenuItem(4, Icons.factory, l10n.suppliers),
                _buildMenuItem(5, Icons.person, l10n.employees),
                _buildMenuItem(6, Icons.people, l10n.customers),
                _buildMenuItem(7, Icons.money, l10n.expenses),
                _buildMenuItem(8, Icons.local_offer, l10n.promo),
                _buildMenuItem(9, Icons.bar_chart, l10n.reports),
                _buildMenuItem(10, Icons.history, l10n.activitiesTitle),
                _buildMenuItem(11, Icons.settings, l10n.settingsTitle),
              ],
            ),
          ),

          // Footer (User Profile)
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;
              if (user == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF7B61FF), // Purple avatar
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2B3C),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            FutureBuilder<Employee?>(
                              future: _employeeRepository.getByUserId(user.id),
                              builder: (context, snapshot) {
                                final phone =
                                    snapshot.data?.phone ?? user.username;
                                return Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.grey),
                        onPressed: () {
                          authProvider.logout();
                          // Navigator.of(context).pushReplacementNamed('/login'); // Handled by main.dart or parent
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData icon,
    String label, {
    bool isGreen = false,
  }) {
    final isSelected = widget.selectedIndex == index;

    // Colors from image
    final activeBgColor = const Color(0xFFD4F59A); // Lime green background
    final activeTextColor = const Color(0xFF1A2B3C); // Dark text
    final inactiveTextColor = const Color(0xFF374759); // Blue-ish grey text

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => widget.onItemSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? activeTextColor : inactiveTextColor,
                size: 24,
              ),
              if (_isExpanded) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? activeTextColor : inactiveTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
