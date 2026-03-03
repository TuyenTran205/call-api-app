import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text(
          'Giới thiệu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.school_rounded, size: 52, color: cs.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Đồ Dùng Học Tập Shop',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          Center(
            child: Text(
              'Phiên bản 1.0.0',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ),
          const SizedBox(height: 28),

          // Thông tin sinh viên
          _InfoCard(
            title: 'Thông tin sinh viên',
            icon: Icons.person_rounded,
            children: const [
              _InfoRow(label: 'Họ và tên', value: 'Trần Văn Tuyên'),
              _InfoRow(label: 'Mã sinh viên', value: '2351060495'),
              _InfoRow(label: 'Môn học', value: 'Phát triển ứng dụng di động'),
              _InfoRow(label: 'Bài tập', value: 'TH3 - Gọi dữ liệu từ mạng'),
            ],
          ),
          const SizedBox(height: 16),

          // Công nghệ
          _InfoCard(
            title: 'Công nghệ sử dụng',
            icon: Icons.code_rounded,
            children: const [
              _InfoRow(label: 'Framework', value: 'Flutter (Dart)'),
              _InfoRow(label: 'Database', value: 'Cloud Firestore'),
              _InfoRow(label: 'Storage', value: 'Firebase Storage'),
              _InfoRow(label: 'UI', value: 'Material Design 3'),
            ],
          ),
          const SizedBox(height: 16),

          // Chức năng
          _InfoCard(
            title: 'Chức năng',
            icon: Icons.check_circle_rounded,
            children: const [
              _InfoRow(label: '✅', value: 'Hiển thị danh sách sản phẩm'),
              _InfoRow(label: '✅', value: 'Thêm sản phẩm mới'),
              _InfoRow(label: '✅', value: 'Sửa thông tin sản phẩm'),
              _InfoRow(label: '✅', value: 'Xóa sản phẩm'),
              _InfoRow(label: '✅', value: 'Chọn ảnh từ thư viện'),
              _InfoRow(label: '✅', value: 'Xử lý lỗi & Retry'),
              _InfoRow(label: '✅', value: 'Thống kê kho hàng'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
