import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';
import 'stats_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];

  // ---- Tìm kiếm & Lọc ----
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCategory; // null = tất cả danh mục
  double? _filterMinPrice;
  double? _filterMaxPrice;

  static const Color _primaryColor = Color(0xFF1565C0);

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

  /// Danh sách sau khi áp dụng tìm kiếm + lọc
  List<Product> get _filteredProducts {
    return _products.where((p) {
      // Tìm kiếm theo tên (có liên quan, không phân biệt hoa thường)
      final query = _searchQuery.toLowerCase().trim();
      if (query.isNotEmpty && !p.name.toLowerCase().contains(query)) {
        return false;
      }
      // Lọc theo danh mục
      if (_filterCategory != null && p.category != _filterCategory) {
        return false;
      }
      // Lọc theo giá tối thiểu
      if (_filterMinPrice != null && p.price < _filterMinPrice!) {
        return false;
      }
      // Lọc theo giá tối đa
      if (_filterMaxPrice != null && p.price > _filterMaxPrice!) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _filterCategory != null ||
      _filterMinPrice != null ||
      _filterMaxPrice != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Load dữ liệu
  // ---------------------------------------------------------------
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await _service.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------
  // Hiện Bottom Sheet lọc: danh mục + khoảng giá
  // ---------------------------------------------------------------
  void _showFilterSheet() {
    // Local state cho bottom sheet (dùng StatefulBuilder)
    String? tempCategory = _filterCategory;
    final minCtrl = TextEditingController(
      text: _filterMinPrice?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: _filterMaxPrice?.toStringAsFixed(0) ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề + nút xóa bộ lọc
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc sản phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setLocal(() => tempCategory = null);
                          minCtrl.clear();
                          maxCtrl.clear();
                        },
                        icon: const Icon(Icons.clear_all_rounded, size: 18),
                        label: const Text('Xóa hết'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // ---- Danh mục ----
                  const Text(
                    'Danh mục',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: tempCategory == null,
                        onSelected: (_) => setLocal(() => tempCategory = null),
                      ),
                      ..._categories.map(
                        (c) => ChoiceChip(
                          label: Text(c),
                          selected: tempCategory == c,
                          onSelected: (_) => setLocal(() => tempCategory = c),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---- Khoảng giá ----
                  const Text(
                    'Khoảng giá (VNĐ)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Từ',
                            prefixIcon: const Icon(Icons.remove),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Đến',
                            prefixIcon: const Icon(Icons.add),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Gợi ý giá nhanh
                  Wrap(
                    spacing: 6,
                    children: [
                      _QuickPriceChip(
                        label: '< 10K',
                        onTap: () {
                          minCtrl.clear();
                          maxCtrl.text = '10000';
                          setLocal(() {});
                        },
                      ),
                      _QuickPriceChip(
                        label: '10K-50K',
                        onTap: () {
                          minCtrl.text = '10000';
                          maxCtrl.text = '50000';
                          setLocal(() {});
                        },
                      ),
                      _QuickPriceChip(
                        label: '50K-200K',
                        onTap: () {
                          minCtrl.text = '50000';
                          maxCtrl.text = '200000';
                          setLocal(() {});
                        },
                      ),
                      _QuickPriceChip(
                        label: '> 200K',
                        onTap: () {
                          minCtrl.text = '200000';
                          maxCtrl.clear();
                          setLocal(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- Nút Áp dụng ----
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        final minVal = double.tryParse(minCtrl.text);
                        final maxVal = double.tryParse(maxCtrl.text);
                        if (minVal != null &&
                            maxVal != null &&
                            minVal > maxVal) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Giá từ phải nhỏ hơn hoặc bằng giá đến',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _filterCategory = tempCategory;
                          _filterMinPrice = minVal;
                          _filterMaxPrice = maxVal;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Mở màn hình Thêm hoặc Sửa
  // ---------------------------------------------------------------
  Future<void> _openAddEdit({Product? product}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
    );
    if (changed == true) {
      _loadProducts(); // tự động reload sau khi thêm/sửa
    }
  }

  // ---------------------------------------------------------------
  // Xóa sản phẩm với dialog xác nhận
  // ---------------------------------------------------------------
  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.red,
          size: 36,
        ),
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa sản phẩm\n"${product.name}"?\n\nThao tác này không thể hoàn tác.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${product.name}"'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadProducts();
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
      }
    }
  }

  // ---------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ---- DRAWER ----
      drawer: _buildDrawer(context),

      // ---- APPBAR ----
      appBar: AppBar(
        title: const Text(
          'TH3 - Trần Văn Tuyên - 2351060495',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Nút lọc (badge đỏ khi có filter đang bật)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                tooltip: 'Lọc sản phẩm',
                onPressed: _showFilterSheet,
              ),
              if (_hasActiveFilter)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Tải lại',
            onPressed: _isLoading ? null : _loadProducts,
          ),
        ],
      ),

      // ---- BODY ----
      body: _buildBody(),

      // ---- FAB thêm sản phẩm ----
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // DRAWER
  // ---------------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          // Header với thông tin user
          DrawerHeader(
            decoration: const BoxDecoration(color: _primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar Google
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 38,
                          color: _primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? 'Người dùng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Menu items
          _DrawerItem(
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerItem(
            icon: Icons.add_circle_rounded,
            label: 'Thêm sản phẩm',
            onTap: () {
              Navigator.pop(context);
              _openAddEdit();
            },
          ),
          _DrawerItem(
            icon: Icons.bar_chart_rounded,
            label: 'Thống kê kho hàng',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _DrawerItem(
            icon: Icons.info_rounded,
            label: 'Giới thiệu',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),

          // Đăng xuất
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Đăng xuất',
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text(
                    'Bạn có chắc muốn đăng xuất khỏi tài khoản Google?',
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await _authService.signOut();
                // StreamBuilder trong main.dart tự điều hướng về LoginScreen
              }
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // BODY: 3 trạng thái
  // ---------------------------------------------------------------
  Widget _buildBody() {
    // LOADING
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryColor, strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // ERROR
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải dữ liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Thử lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // SUCCESS (empty - chưa có sản phẩm nào trên Firestore)
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Chưa có sản phẩm nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openAddEdit(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm sản phẩm đầu tiên'),
            ),
          ],
        ),
      );
    }

    // SUCCESS (có data)
    final filtered = _filteredProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // --- Responsive grid ---
        final int crossAxisCount;
        final double aspectRatio;
        if (w > 1400) {
          crossAxisCount = 5;
          aspectRatio = 0.56;
        } else if (w > 1100) {
          crossAxisCount = 4;
          aspectRatio = 0.60;
        } else if (w > 700) {
          crossAxisCount = 3;
          aspectRatio = 0.63;
        } else {
          crossAxisCount = 2;
          aspectRatio = 0.65;
        }

        // Trên web rộng, thu hẹp vùng search+filter để đẹp hơn
        final double hPad = w > 900 ? (w - 900) / 2 : 0;

        Widget searchBar = Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(12 + hPad, 10, 12 + hPad, 6),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _primaryColor,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF0F4FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );

        return Column(
          children: [
            // ---- Thanh tìm kiếm ----
            searchBar,

            // ---- Chips bộ lọc đang active ----
            if (_hasActiveFilter)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12 + hPad, 0, 12 + hPad, 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (_filterCategory != null)
                      _ActiveFilterChip(
                        label: _filterCategory!,
                        onRemove: () => setState(() => _filterCategory = null),
                      ),
                    if (_filterMinPrice != null || _filterMaxPrice != null)
                      _ActiveFilterChip(
                        label: _buildPriceLabel(),
                        onRemove: () => setState(() {
                          _filterMinPrice = null;
                          _filterMaxPrice = null;
                        }),
                      ),
                  ],
                ),
              ),

            // ---- Thanh info ----
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16 + hPad, 8, 16 + hPad, 8),
              color: const Color(0xFFF5F6FA),
              child: Row(
                children: [
                  const Icon(Icons.school, color: _primaryColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    filtered.isEmpty
                        ? 'Không tìm thấy sản phẩm nào'
                        : 'Tìm thấy ${filtered.length} / ${_products.length} sản phẩm',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // ---- GridView hoặc thông báo rỗng ----
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy kết quả phù hợp',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _clearAllFilters,
                            icon: const Icon(Icons.clear_all_rounded),
                            label: const Text('Xóa bộ lọc'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      color: _primaryColor,
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          12 + hPad,
                          12,
                          12 + hPad,
                          80,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return ProductCard(
                            product: p,
                            onEdit: () => _openAddEdit(product: p),
                            onDelete: () => _confirmDelete(p),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ---- Helpers ----
  String _buildPriceLabel() {
    if (_filterMinPrice != null && _filterMaxPrice != null) {
      return '${_fmt(_filterMinPrice!)} - ${_fmt(_filterMaxPrice!)}';
    } else if (_filterMinPrice != null) {
      return '≥ ${_fmt(_filterMinPrice!)}';
    } else {
      return '≤ ${_fmt(_filterMaxPrice!)}';
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  void _clearAllFilters() {
    setState(() {
      _searchCtrl.clear();
      _filterCategory = null;
      _filterMinPrice = null;
      _filterMaxPrice = null;
    });
  }
}

// ---------------------------------------------------------------
// Drawer menu item widget
// ---------------------------------------------------------------
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      horizontalTitleGap: 8,
    );
  }
}

// ---------------------------------------------------------------
// Chip hiển thị bộ lọc đang active (có nút ×)
// ---------------------------------------------------------------
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      deleteIcon: Icon(Icons.close_rounded, size: 14, color: cs.primary),
      onDeleted: onRemove,
      backgroundColor: cs.primaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ---------------------------------------------------------------
// Chip gợi ý khoảng giá nhanh
// ---------------------------------------------------------------
class _QuickPriceChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPriceChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
