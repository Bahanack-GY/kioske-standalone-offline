import 'package:flutter/material.dart';
import 'package:kioske/models/order.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/providers/settings_provider.dart';
import 'package:kioske/services/receipt_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';

class SaleSuccessDialog extends StatefulWidget {
  final double total;
  final String orderId;
  final List<OrderItem> items;
  final String? customerName;
  final String paymentMethod;

  const SaleSuccessDialog({
    super.key,
    required this.total,
    required this.orderId,
    required this.items,
    this.customerName,
    this.paymentMethod = 'cash',
  });

  @override
  State<SaleSuccessDialog> createState() => _SaleSuccessDialogState();
}

class _SaleSuccessDialogState extends State<SaleSuccessDialog> {
  late List<OrderItem> _items;
  late double _currentTotal;
  bool _isEditing = false;
  final Map<int, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _currentTotal = widget.total;
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateItemPrice(int index, String value) {
    if (value.isEmpty) return;

    final newPrice = double.tryParse(value);
    if (newPrice == null) return;

    setState(() {
      final oldItem = _items[index];
      // Create a copy with the new unit price (assuming the edit represents unit price)
      // Or if edit represents TOTAL price for that line item.
      // Usually "Edit Price" edits the unit price. Let's assume Unit Price.

      _items[index] = oldItem.copyWith(unitPrice: newPrice);

      // Recalculate total
      _currentTotal = _items.fold(0, (sum, item) => sum + item.total);
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // Initialize controllers
        for (int i = 0; i < _items.length; i++) {
          _priceControllers[i] = TextEditingController(
            text: _items[i].unitPrice.toStringAsFixed(0),
          );
        }
      } else {
        _priceControllers.clear();
      }
    });
  }

  void _showPreview(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final user = context.read<AuthProvider>().currentUser?.name;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          height: 700,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aperçu du reçu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: PdfPreview(
                  build: (format) => ReceiptService.generateReceiptData(
                    items: _items,
                    total: _currentTotal,
                    orderId: widget.orderId,
                    settingsProvider: settings,
                    user: user,
                    customerName: widget.customerName,
                    paymentMethod: widget.paymentMethod,
                  ),
                  allowPrinting: true,
                  allowSharing: true,
                  initialPageFormat: PdfPageFormat.roll80,
                  pdfFileName: 'Receipt_${widget.orderId.substring(0, 8)}.pdf',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 500, // Widened to accommodate table
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isEditing) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Vente réussie !',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La commande #${widget.orderId.substring(0, 8).toUpperCase()} a été enregistrée.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ] else ...[
              Text(
                'Modifier les prix',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ces modifications n\'affecteront pas la base de données.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
              ),
            ],

            const SizedBox(height: 24),

            if (_isEditing)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${item.quantity} x',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _priceControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Prix Unit.',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => _updateItemPrice(index, val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${item.total.toStringAsFixed(0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_currentTotal.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isEditing
                          ? Colors.orange
                          : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Nouvelle vente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _toggleEditMode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(_isEditing ? 'Terminer' : 'Modifier prix'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showPreview(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('Aperçu'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final settings = context.read<SettingsProvider>();
                    final user = context.read<AuthProvider>().currentUser?.name;
                    ReceiptService.printReceipt(
                      items: _items,
                      total: _currentTotal,
                      orderId: widget.orderId,
                      settingsProvider: settings,
                      user: user,
                      customerName: widget.customerName,
                      paymentMethod: widget.paymentMethod,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.print_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('Imprimer'),
                    ],
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
