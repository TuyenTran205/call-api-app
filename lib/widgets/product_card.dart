import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  // Màu sắc theo category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bút viết':
        return Colors.blue;
      case 'Vở - Sổ':
        return Colors.green;
      case 'Dụng cụ vẽ':
        return Colors.orange;
      case 'Thiết bị':
        return Colors.purple;
      case 'Phụ kiện':
        return Colors.teal;
      case 'Dụng cụ':
        return Colors.red;
      case 'Túi - Balo':
        return Colors.brown;
      case 'Giấy tờ':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  // Icon theo category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bút viết':
        return Icons.edit;
      case 'Vở - Sổ':
        return Icons.menu_book;
      case 'Dụng cụ vẽ':
        return Icons.architecture;
      case 'Thiết bị':
        return Icons.calculate;
      case 'Phụ kiện':
        return Icons.cases;
      case 'Dụng cụ':
        return Icons.content_cut;
      case 'Túi - Balo':
        return Icons.backpack;
      case 'Giấy tờ':
        return Icons.description;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(product.category);
    final formattedPrice = _formatPrice(product.price);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần hình ảnh + nút hành động
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                color: categoryColor.withValues(alpha: 0.15),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: categoryColor,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            _getCategoryIcon(product.category),
                            size: 48,
                            color: categoryColor,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
                          size: 48,
                          color: categoryColor,
                        ),
                      ),
              ),
              // Nút Sửa & Xóa
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  children: [
                    _ActionBtn(
                      icon: Icons.edit_rounded,
                      color: Colors.blue,
                      tooltip: 'Sửa',
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 4),
                    _ActionBtn(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      tooltip: 'Xóa',
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge danh mục
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Tên sản phẩm
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Mô tả
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Giá & tồn kho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Còn ${product.stock}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    // Định dạng giá theo VND không dùng intl package
    final parts = price.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parts[i]);
    }
    return '${buffer.toString()} đ';
  }
}

// Nút hành động nhỏ trên card (sửa / xóa)
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
