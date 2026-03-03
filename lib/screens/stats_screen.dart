import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _service = FirebaseService();
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchProducts();
      setState(() {
        _products = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Tổng hợp theo danh mục
    final Map<String, int> countByCategory = {};
    for (final p in _products) {
      countByCategory[p.category] = (countByCategory[p.category] ?? 0) + 1;
    }
    final totalValue = _products.fold<double>(
      0,
      (sum, p) => sum + p.price * p.stock,
    );
    final totalStock = _products.fold<int>(0, (sum, p) => sum + p.stock);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text(
          'Thống kê kho hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 56, color: cs.error),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.error),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Tổng quan
                  _SummaryRow(
                    items: [
                      _SummaryItem(
                        icon: Icons.inventory_2_rounded,
                        color: cs.primary,
                        label: 'Loại SP',
                        value: '${_products.length}',
                      ),
                      _SummaryItem(
                        icon: Icons.layers_rounded,
                        color: Colors.green,
                        label: 'Tổng tồn',
                        value: '$totalStock',
                      ),
                      _SummaryItem(
                        icon: Icons.attach_money_rounded,
                        color: Colors.orange,
                        label: 'Giá trị kho',
                        value: _formatCompact(totalValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Theo danh mục
                  Text(
                    'Theo danh mục',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...countByCategory.entries.map((e) {
                    final percent = _products.isEmpty
                        ? 0.0
                        : e.value / _products.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${e.value} sản phẩm',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: percent,
                                backgroundColor: cs.surfaceContainerHighest,
                                color: cs.primary,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M đ';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K đ';
    }
    return '${value.toStringAsFixed(0)} đ';
  }
}

class _SummaryRow extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: item.color.withValues(alpha: 0.15),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: item.color,
                        ),
                      ),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
}
