import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/providers/auth_provider.dart';

import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/supplier_provider.dart';
import 'package:kioske/providers/supply_delivery_provider.dart';

class NewDeliveryModal extends StatefulWidget {
  const NewDeliveryModal({super.key});

  @override
  State<NewDeliveryModal> createState() => _NewDeliveryModalState();
}

class _NewDeliveryModalState extends State<NewDeliveryModal> {
  String? _selectedSupplierId;
  DateTime _selectedDate = DateTime.now();
  File? _deliverySlip;
  final ImagePicker _picker = ImagePicker();

  // Temporary list of selected items
  final Map<String, int> _quantities = {};
  final Map<String, Product> _selectedProducts = {}; // To keep product ref

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().loadSuppliers();
      context.read<ProductProvider>().loadProducts();
    });
  }

  Future<void> _pickDeliverySlip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _deliverySlip = File(image.path);
      });
    }
  }

  void _onProductTap(Product product) {
    setState(() {
      if (_quantities.containsKey(product.id)) {
        _quantities[product.id] = _quantities[product.id]! + 1;
      } else {
        _quantities[product.id] = 1;
        _selectedProducts[product.id] = product;
      }
    });
  }

  void _removeProduct(String productId) {
    setState(() {
      _quantities.remove(productId);
      _selectedProducts.remove(productId);
    });
  }

  Future<void> _createDelivery() async {
    if (_selectedSupplierId == null || _quantities.isEmpty) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      String? proofImageBase64;
      if (_deliverySlip != null) {
        final bytes = await _deliverySlip!.readAsBytes();
        proofImageBase64 = base64Encode(bytes);
      }

      final itemsData = _quantities.entries.map((entry) {
        final product = _selectedProducts[entry.key]!;
        // Use purchasePrice as unit_price default
        return {
          'product_id': product.id,
          'product_name': product.name,
          'quantity': entry.value,
          'unit_price': product.purchasePrice,
        };
      }).toList();

      await context.read<SupplyDeliveryProvider>().createDelivery(
        supplierId: _selectedSupplierId!,
        expectedDate: _selectedDate,
        itemsData: itemsData,
        proofImage: proofImageBase64,
        notes: "Created via Admin Panel",
        currentUserId:
            context.read<AuthProvider>().currentUser?.id ?? 'unknown',
        currentUserName: context.read<AuthProvider>().currentUser?.name,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final products = context.watch<ProductProvider>().products;

    // Filter available products or all products? All products for new delivery import.

    // Sort logic could go here if needed

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 100 : 16,
        vertical: 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 1000,
        height: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.newDelivery,
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

            // Top Row: Supplier & Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.vendor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSupplierId,
                            hint: Text(l10n.select ?? 'Select'),
                            isExpanded: true,
                            items: suppliers.map((s) {
                              return DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSupplierId = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.deliveryDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content Area: Split View
            Expanded(
              child: Row(
                children: [
                  // Left: Product Selection (Grid)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectProducts,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 2.2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final p = products[index];
                                final isSelected = _quantities.containsKey(
                                  p.id,
                                );
                                return InkWell(
                                  onTap: () => _onProductTap(p),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "${p.purchasePrice.toStringAsFixed(0)} FCFA",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        if (isSelected)
                                          Text(
                                            "${_quantities[p.id]}x",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right: Selected Items List
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Items (${_quantities.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.separated(
                              itemCount: _quantities.length,
                              separatorBuilder: (c, i) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final productId = _quantities.keys.elementAt(
                                  index,
                                );
                                final qty = _quantities[productId]!;
                                final p = _selectedProducts[productId]!;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text('${p.purchasePrice} FCFA'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (qty > 1) {
                                              _quantities[productId] = qty - 1;
                                            } else {
                                              _removeProduct(productId);
                                            }
                                          });
                                        },
                                      ),
                                      Text('$qty'),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () {
                                          setState(() {
                                            _quantities[productId] = qty + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Box & Upload (Simplified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    size: 20,
                    color: Color(0xFF1E40AF),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.deliverySlipInfo,
                      style: const TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_deliverySlip != null) ...[
                    // Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        _deliverySlip!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _deliverySlip = null),
                    ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: _pickDeliverySlip,
                      icon: const Icon(
                        Icons.upload_file,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.uploadSlip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (_selectedSupplierId != null && _quantities.isNotEmpty)
                        ? _createDelivery
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.createDelivery,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
