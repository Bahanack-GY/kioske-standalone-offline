import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/models/supply_delivery.dart';
import 'package:kioske/providers/supply_delivery_provider.dart';
import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/stock_provider.dart';
import 'package:kioske/providers/auth_provider.dart';

class ConfirmDeliveryModal extends StatefulWidget {
  final SupplyDelivery delivery;

  const ConfirmDeliveryModal({super.key, required this.delivery});

  @override
  State<ConfirmDeliveryModal> createState() => _ConfirmDeliveryModalState();
}

class _ConfirmDeliveryModalState extends State<ConfirmDeliveryModal> {
  String _paymentMethod = 'cash'; // cash, mobile_money
  File? _deliverySlip;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDeliverySlip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _deliverySlip = File(image.path);
      });
    }
  }

  Future<void> _confirm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<SupplyDeliveryProvider>();

    try {
      String proofImageBase64 = widget.delivery.proofImage ?? '';

      if (_deliverySlip != null) {
        final bytes = await _deliverySlip!.readAsBytes();
        proofImageBase64 = base64Encode(bytes);
      }

      if (proofImageBase64.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Please upload a delivery slip/bordereau'),
          ),
        );
        return;
      }

      await provider.confirmDelivery(
        widget.delivery.id,
        proofImageBase64,
        currentUserId:
            context.read<AuthProvider>().currentUser?.id ?? 'unknown',
        currentUserName: context.read<AuthProvider>().currentUser?.name,
      );

      if (mounted) {
        context.read<ProductProvider>().loadProducts();
        context.read<StockProvider>().loadProducts();
        Navigator.pop(context);
      }
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
    final currencyFormat = NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Check if we already have a slip
    final hasExistingSlip =
        widget.delivery.proofImage != null &&
        widget.delivery.proofImage!.isNotEmpty;
    final hasSlip = _deliverySlip != null || hasExistingSlip;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 100 : 16,
        vertical: 24,
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.confirmDeliveryTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46), // Dark Green Text
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deliveryDetails,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          l10n.vendor,
                          widget.delivery.supplierName,
                        ),
                        _buildDetailItem(
                          l10n.dateTime,
                          dateFormat.format(widget.delivery.createdAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          l10n.totalAmount,
                          currencyFormat.format(widget.delivery.totalAmount),
                          isGreen: true,
                        ),
                        _buildDetailItem(
                          l10n.numberOfItems,
                          "${widget.delivery.itemCount}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.paymentMethod,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentButton(
                            l10n.cash,
                            Icons.money,
                            'cash',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPaymentButton(
                            l10n.mobileMoney,
                            Icons.smartphone,
                            'mobile_money',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.paymentDeductionInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Slips Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.image,
                          size: 18,
                          color: Color(0xFF1A2B3C),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.deliverySlipsMandatory,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.addSlipImages,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // File Picker Area
                    InkWell(
                      onTap: _pickDeliverySlip,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _deliverySlip != null
                              ? _deliverySlip!.path.split('/').last
                              : l10n.browseFiles,
                          style: TextStyle(
                            color: _deliverySlip != null
                                ? Colors.black87
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mandatorySlipWarning,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Placeholder / Preview
                    Center(
                      child: _deliverySlip != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _deliverySlip!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : hasExistingSlip
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(widget.delivery.proofImage!),
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.noSlipSelectedMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ],
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
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
                      onPressed: hasSlip ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.white,
                        backgroundColor: const Color(
                          0xFF10B981,
                        ), // Green when active
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.confirmDelivery,
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
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isGreen ? const Color(0xFF10B981) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String label, IconData icon, String value) {
    bool isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF10B981) : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF10B981) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
