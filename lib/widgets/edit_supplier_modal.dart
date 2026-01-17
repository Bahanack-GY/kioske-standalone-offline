import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/supplier.dart';
import 'package:kioske/providers/supplier_provider.dart';

class EditSupplierModal extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierModal({super.key, required this.supplier});

  @override
  State<EditSupplierModal> createState() => _EditSupplierModalState();
}

class _EditSupplierModalState extends State<EditSupplierModal> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _contactPersonController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _phoneController = TextEditingController(text: widget.supplier.phone);
    _addressController = TextEditingController(text: widget.supplier.address);
    _emailController = TextEditingController(text: widget.supplier.email);
    _contactPersonController = TextEditingController(
      text: widget.supplier.contactPerson,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLoading = context.watch<SupplierProvider>().isLoading;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 100 : 16,
        vertical: 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 800,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.editSupplierTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.supplierName,
                      "",
                      _nameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(l10n.whatsapp, "", _phoneController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.neighborhoodOptional,
                      "",
                      _addressController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      "Contact Person",
                      "",
                      _contactPersonController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Email", "", _emailController),

              const SizedBox(height: 24),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: const Color(0xFF374151),
                    ),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Name is required"),
                                ),
                              );
                              return;
                            }

                            try {
                              final updatedSupplier = widget.supplier.copyWith(
                                name: name,
                                phone: _phoneController.text.trim().isEmpty
                                    ? null
                                    : _phoneController.text.trim(),
                                address: _addressController.text.trim().isEmpty
                                    ? null
                                    : _addressController.text.trim(),
                                email: _emailController.text.trim().isEmpty
                                    ? null
                                    : _emailController.text.trim(),
                                contactPerson:
                                    _contactPersonController.text.trim().isEmpty
                                    ? null
                                    : _contactPersonController.text.trim(),
                              );

                              await context
                                  .read<SupplierProvider>()
                                  .updateSupplier(updatedSupplier);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.saveChanges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
