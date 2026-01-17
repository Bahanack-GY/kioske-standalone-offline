import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/l10n/app_localizations.dart';

import 'package:kioske/models/promotion.dart';
import 'package:kioske/providers/promotion_provider.dart';
import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:provider/provider.dart';

class NewPromotionModal extends StatefulWidget {
  final Promotion? promotion;

  const NewPromotionModal({super.key, this.promotion});

  @override
  State<NewPromotionModal> createState() => _NewPromotionModalState();
}

class _NewPromotionModalState extends State<NewPromotionModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = 'Pourcentage'; // Default
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });

    if (widget.promotion != null) {
      _titleController.text = widget.promotion!.title;
      _valueController.text = widget.promotion!.value.toString();
      _selectedType = widget.promotion!.type;
      _descriptionController.text = widget.promotion!.description ?? '';
      _startDate = widget.promotion!.startDate;
      _endDate = widget.promotion!.endDate;
      _selectedProductId = widget.promotion!.productId;
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 100 : 16,
        vertical: 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 1100,
        height: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFields(l10n),
                    const SizedBox(height: 24),
                    _buildConditionsSection(l10n),
                    const SizedBox(height: 24),
                    _buildProductsSection(l10n),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFooter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.promotion == null
              ? l10n.createPromotionTitle
              : "Modifier la promotion",
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
    );
  }

  Widget _buildFormFields(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.promotionTitle,
                "",
                controller: _titleController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(l10n.promotionType, [
                l10n.percentage,
                l10n.fixedAmount,
                l10n.buyXGetY,
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.discountValue,
                "0",
                controller: _valueController,
                suffix: _selectedType == l10n.percentage ? "%" : "FCFA",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(
                l10n.startDate,
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                l10n.endDate,
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Container()),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.expenseDescription,
          "",
          controller: _descriptionController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildConditionsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.applicationConditions,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: Text(l10n.addCondition),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(AppLocalizations l10n) {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProvider, categoryProvider, child) {
        final products = productProvider.products;

        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.applicableProducts,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: products.isEmpty
                  ? const Center(child: Text('Aucun produit disponible'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final category = categoryProvider.getCategoryById(
                          product.categoryId,
                        );
                        final isSelected = _selectedProductId == product.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedProductId = null;
                              } else {
                                _selectedProductId = product.id;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category?.name ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: const Color(0xFF374151),
            ),
            child: Text("Annuler"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty ||
                  _valueController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir les champs obligatoires'),
                  ),
                );
                return;
              }

              try {
                final provider = context.read<PromotionProvider>();
                final double value =
                    double.tryParse(_valueController.text) ?? 0;

                if (widget.promotion != null) {
                  await provider.updatePromotion(
                    widget.promotion!.copyWith(
                      title: _titleController.text,
                      type: _selectedType,
                      value: value,
                      description: _descriptionController.text,
                      startDate: _startDate,
                      endDate: _endDate,
                      productId: _selectedProductId,
                    ),
                  );
                } else {
                  await provider.addPromotion(
                    title: _titleController.text,
                    type: _selectedType,
                    value: value,
                    description: _descriptionController.text,
                    startDate: _startDate ?? DateTime.now(),
                    endDate:
                        _endDate ??
                        DateTime.now().add(const Duration(days: 30)),
                    productId: _selectedProductId,
                  );
                }
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: Colors.white,
            ),
            child: Text(
              widget.promotion != null ? "Modifier" : l10n.createPromotion,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder, {
    TextEditingController? controller,
    String? suffix,
    int maxLines = 1,
  }) {
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixText: suffix,
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

  Widget _buildDropdownField(String label, List<String> items) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(_selectedType)
                  ? _selectedType
                  : items.first,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onSelect,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDate: selectedDate ?? DateTime.now(),
            );
            if (date != null) onSelect(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('MM/dd/yyyy').format(selectedDate)
                      : "",
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
