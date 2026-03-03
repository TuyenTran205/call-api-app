import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class AddEditProductScreen extends StatefulWidget {
  /// null = chế độ thêm mới; có giá trị = chế độ sửa
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseService();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageUrlCtrl;

  String _selectedCategory = 'Bút viết';
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  static const List<String> _categories = [
    'Bút viết',
    'Vở - Sổ',
    'Dụng cụ vẽ',
    'Thiết bị',
    'Phụ kiện',
    'Dụng cụ',
    'Túi - Balo',
    'Giấy tờ',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _stockCtrl = TextEditingController(
      text: p != null ? p.stock.toString() : '',
    );
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    if (p != null) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Lưu sản phẩm
  // ------------------------------------------------------------------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
        category: _selectedCategory,
        stock: int.parse(_stockCtrl.text.trim()),
      );

      if (_isEditing) {
        await _service.updateProduct(product);
      } else {
        await _service.addProduct(product);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: Text(
          _isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Ảnh sản phẩm (URL) ----
              _buildImageSection(),
              const SizedBox(height: 20),

              // ---- Tên sản phẩm ----
              _buildLabel('Tên sản phẩm *'),
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDeco('VD: Bút bi Thiên Long TL-027'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  if (v.trim().length < 3) {
                    return 'Tên phải có ít nhất 3 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Giá ----
              _buildLabel('Giá tiền (VNĐ) *'),
              TextFormField(
                controller: _priceCtrl,
                decoration: _inputDeco('VD: 25000'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập giá tiền';
                  }
                  final price = double.tryParse(v.trim());
                  if (price == null) return 'Giá tiền phải là số';
                  if (price <= 0) return 'Giá tiền phải lớn hơn 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Danh mục ----
              _buildLabel('Danh mục *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _inputDeco(null),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),

              // ---- Số lượng tồn kho ----
              _buildLabel('Số lượng tồn kho *'),
              TextFormField(
                controller: _stockCtrl,
                decoration: _inputDeco('VD: 100'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  final stock = int.tryParse(v.trim());
                  if (stock == null) return 'Số lượng phải là số nguyên';
                  if (stock < 0) return 'Số lượng không được âm';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Mô tả ----
              _buildLabel('Mô tả sản phẩm'),
              TextFormField(
                controller: _descCtrl,
                decoration: _inputDeco('Mô tả ngắn về sản phẩm...'),
                maxLines: 4,
                maxLength: 300,
              ),
              const SizedBox(height: 24),

              // ---- Nút Lưu ----
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? 'Đang lưu...'
                        : (_isEditing ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Widget phần nhập URL ảnh
  // ------------------------------------------------------------------
  Widget _buildImageSection() {
    final urlText = _imageUrlCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Ảnh sản phẩm (URL)'),
        // Preview ảnh nếu URL hợp lệ
        if (urlText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                urlText,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Ảnh không tải được',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
        TextFormField(
          controller: _imageUrlCtrl,
          decoration: _inputDeco('https://example.com/image.jpg').copyWith(
            prefixIcon: const Icon(Icons.link_rounded),
            suffixIcon: _imageUrlCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _imageUrlCtrl.clear()),
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String? hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
