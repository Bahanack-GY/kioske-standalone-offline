import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:kioske/models/category.dart' as model;

class CategoryModal extends StatefulWidget {
  final model.Category? category; // For editing existing category
  final VoidCallback? onSaved;

  const CategoryModal({super.key, this.category, this.onSaved});

  @override
  State<CategoryModal> createState() => _CategoryModalState();
}

class _CategoryModalState extends State<CategoryModal> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  final List<Color> _colors = [
    const Color(0xFF3B82F6),
    const Color(0xFFEF4444),
    const Color(0xFF10B981),
    const Color(0xFFA855F7),
    const Color(0xFFF59E0B),
    const Color(0xFFEC4899),
    const Color(0xFF6366F1),
    const Color(0xFF14B8A6),
  ];

  Color _selectedColor = const Color(0xFF3B82F6);
  IconData _selectedIcon = Icons.category;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<CategoryProvider>();

      if (isEditing) {
        // Update existing category
        final updated = widget.category!.copyWith(
          name: _nameController.text.trim(),
        );
        await provider.updateCategory(updated);
      } else {
        // Add new category
        await provider.addCategory(name: _nameController.text.trim());
      }

      widget.onSaved?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving category: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        horizontal: screenWidth > 600 ? 0 : 16,
        vertical: 24,
      ),
      child: Container(
        width: 500,
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
                    isEditing
                        ? l10n.editProductCategory
                        : l10n.addProductCategory,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              _buildInput(l10n.categoryName, _nameController),
              const SizedBox(height: 24),

              // Color and Icon Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildColorPicker(l10n)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildIconPreview(l10n)),
                ],
              ),
              const SizedBox(height: 24),

              // Icon Selection
              _buildIconSelection(l10n),
              const SizedBox(height: 40),

              // Actions
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
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? l10n.update : l10n.addCategoryAction,
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
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.color,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((color) {
            final isSelected = _selectedColor == color;
            return InkWell(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconPreview(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.icon,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(_selectedIcon, color: _selectedColor),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.selectedIcon,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconGroup(l10n.foodAndDrinks, [
          Icons.restaurant,
          Icons.local_bar,
          Icons.local_cafe,
          Icons.local_drink,
          Icons.liquor,
          Icons.wine_bar,
          Icons.water_drop,
          Icons.local_pizza,
        ]),
        const SizedBox(height: 16),
        _buildIconGroup('Général', [
          Icons.category,
          Icons.shopping_bag,
          Icons.inventory_2,
          Icons.store,
          Icons.sell,
          Icons.local_offer,
          Icons.widgets,
          Icons.apps,
        ]),
      ],
    );
  }

  Widget _buildIconGroup(String title, List<IconData> icons) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
          const Divider(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: icons.map((icon) {
              final isSelected = _selectedIcon == icon;
              return InkWell(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
                    border: isSelected
                        ? Border.all(color: const Color(0xFF3B82F6))
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : Colors.grey.shade600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
