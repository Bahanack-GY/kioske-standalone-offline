import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:kioske/widgets/category_modal.dart';

class StockEditModal extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>)? onSave;

  const StockEditModal({super.key, required this.product, this.onSave});

  @override
  State<StockEditModal> createState() => _StockEditModalState();
}

class _StockEditModalState extends State<StockEditModal> {
  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _maxStockController;
  late TextEditingController _minStockController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategoryId;
  String? _selectedUnit = "Pieces";

  final List<String> _units = ["Pieces", "Kg", "Litre", "Pack"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _stockController = TextEditingController(text: widget.product['stock']);
    _maxStockController = TextEditingController(text: "100");
    _minStockController = TextEditingController(text: "5");
    _purchasePriceController = TextEditingController(
      text: widget.product['purchasePrice'] ?? widget.product['price'] ?? "0",
    );
    _salePriceController = TextEditingController(
      text: widget.product['salePrice'] ?? "0",
    );
    _selectedCategoryId = widget.product['categoryId'];

    // Load categories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _maxStockController.dispose();
    _minStockController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth > 600 ? 0 : 16,
            vertical: 24,
          ),
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.editProduct,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Row 1: Name and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInput(l10n.productName, _nameController),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildCategorySection(l10n, categoryProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Row 2: Prices
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          "${l10n.purchasePrice} (FCFA)",
                          _purchasePriceController,
                          isNumber: true,
                          hasControls: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildInput(
                          "${l10n.salePrice} (FCFA)",
                          _salePriceController,
                          isNumber: true,
                          hasControls: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Row 3: Stocks
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          l10n.currentStock,
                          _stockController,
                          isNumber: true,
                          hasControls: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildInput(
                          l10n.minStock,
                          _minStockController,
                          isNumber: true,
                          hasControls: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Row 4: Max Stock & Unit
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          l10n.maxStock,
                          _maxStockController,
                          isNumber: true,
                          hasControls: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildDropdown(
                          l10n,
                          l10n.unit,
                          _units,
                          _selectedUnit,
                          (val) => setState(() => _selectedUnit = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Image Picker
                  _buildImagePicker(l10n),
                  const SizedBox(height: 48),

                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.onSave != null) {
                            String? imageBase64 = await _getBase64Image();
                            widget.onSave!({
                              'name': _nameController.text,
                              'stock': _stockController.text,
                              'purchasePrice': _purchasePriceController.text,
                              'salePrice': _salePriceController.text,
                              'categoryId': _selectedCategoryId,
                              'imageUrl': imageBase64,
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.update,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildCategorySection(
    AppLocalizations l10n,
    CategoryProvider categoryProvider,
  ) {
    final categories = categoryProvider.categories;

    // Validate that selected category exists in the list
    final categoryExists =
        _selectedCategoryId != null &&
        categories.any((c) => c.id == _selectedCategoryId);

    // Reset to first category if current selection is invalid
    if (!categoryExists && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    } else if (!categoryExists && categories.isEmpty) {
      _selectedCategoryId = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
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
          child: categoryProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : categories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Aucune catégorie',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: const Text('Sélectionner une catégorie'),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CategoryModal(
                      onSaved: () => categoryProvider.loadCategories(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(
                  l10n.addProductCategory,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedCategoryId != null
                    ? () => _confirmDeleteCategory(categoryProvider, l10n)
                    : null,
                icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDeleteCategory(
    CategoryProvider categoryProvider,
    AppLocalizations l10n,
  ) {
    final category = categoryProvider.getCategoryById(_selectedCategoryId!);
    if (category == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer catégorie'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${category.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await categoryProvider.deleteCategory(category.id);
              if (categoryProvider.categories.isNotEmpty) {
                _selectedCategoryId = categoryProvider.categories.first.id;
              } else {
                _selectedCategoryId = null;
              }
              setState(() {});
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool hasControls = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
            ),
            if (hasControls)
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final current = int.tryParse(controller.text) ?? 0;
                        controller.text = (current + 1).toString();
                      },
                      child: const Icon(
                        Icons.arrow_drop_up,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final current = int.tryParse(controller.text) ?? 0;
                        if (current > 0)
                          controller.text = (current - 1).toString();
                      },
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    AppLocalizations l10n,
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
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
              value: value,
              isExpanded: true,
              items: items
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _getBase64Image() async {
    if (_selectedImage == null) {
      // Return existing image URL if no new image was selected
      return widget.product['imageUrl'];
    }
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      // Prefix with data URI for easy image display
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error encoding image: $e');
      return null;
    }
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.image,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          _selectedImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedImage != null
                            ? _selectedImage!.path.split('/').last
                            : l10n.noFileSelected,
                        style: const TextStyle(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(l10n.browse),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
