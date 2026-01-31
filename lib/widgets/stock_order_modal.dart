import 'package:flutter/material.dart';
import 'package:kioske/l10n/app_localizations.dart';

class StockOrderModal extends StatefulWidget {
  final String productName;
  final String currentPrice;

  const StockOrderModal({
    super.key,
    required this.productName,
    required this.currentPrice,
  });

  @override
  State<StockOrderModal> createState() => _StockOrderModalState();
}

class _StockOrderModalState extends State<StockOrderModal> {
  final _quantityController = TextEditingController(text: "0");
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  // Sample Suppliers
  final List<String> _suppliers = [
    "Shekina",
    "Brasseries",
    "Guinness",
    "Coca-Cola",
    "Other",
  ];
  String? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    // sanitize price string to number for init if needed, or just set empty
    // Keeping it 0 as per image
    _priceController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500, // Fixed width for nice form factor
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Commander - ${widget.productName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity
            _buildLabel(l10n.quantityToOrder),
            const SizedBox(height: 8),
            _buildNumberInput(_quantityController),
            const SizedBox(height: 16),

            // Supplier
            _buildLabel("${l10n.supplier} *"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSupplier,
                  hint: Text(
                    l10n.selectSupplier,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  items: _suppliers
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSupplier = val),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Unit Price
            _buildLabel("${l10n.unitPrice} (FCFA) *"),
            const SizedBox(height: 8),
            _buildNumberInput(_priceController),
            const SizedBox(height: 16),

            // Notes
            _buildLabel(l10n.notesOptional),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.notesPlaceholder,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Confirm logic
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(
                        0xFF90949D,
                      ), // Greyish blue from image
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.confirmOrder,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // Debug text from image? "0" below notes. Just hiding it.
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  Widget _buildNumberInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        suffixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.unfold_more, size: 16, color: Colors.grey),
          ], // Sort of looks like spinner
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
    );
  }
}
