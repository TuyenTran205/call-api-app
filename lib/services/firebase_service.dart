import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // ---------------------------------------------------------------
  // READ: Lấy toàn bộ sản phẩm
  // ---------------------------------------------------------------
  Future<List<Product>> fetchProducts() async {
    try {
      final snapshot = await _db.collection(_collection).orderBy('name').get();

      if (snapshot.docs.isEmpty) {
        await _seedSampleProducts();
        final seeded = await _db.collection(_collection).orderBy('name').get();
        return seeded.docs.map((doc) => Product.fromFirestore(doc)).toList();
      }

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Không thể tải dữ liệu: $e');
    }
  }

  // ---------------------------------------------------------------
  // CREATE: Thêm sản phẩm mới
  // ---------------------------------------------------------------
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection(_collection).add(product.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Không thể thêm sản phẩm: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ---------------------------------------------------------------
  // UPDATE: Cập nhật sản phẩm
  // ---------------------------------------------------------------
  Future<void> updateProduct(Product product) async {
    try {
      await _db.collection(_collection).doc(product.id).update(product.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ---------------------------------------------------------------
  // DELETE: Xóa sản phẩm
  // ---------------------------------------------------------------
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Không thể xóa sản phẩm: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ---------------------------------------------------------------
  // Seed dữ liệu mẫu
  // ---------------------------------------------------------------
  Future<void> _seedSampleProducts() async {
    final List<Map<String, dynamic>> sampleData = [
      {
        'name': 'Bút bi Thiên Long TL-027',
        'price': 5000.0,
        'description':
            'Bút bi cao cấp, mực đều, không lem. Phù hợp cho học sinh, sinh viên.',
        'imageUrl': 'https://picsum.photos/seed/pen/400/300',
        'category': 'Bút viết',
        'stock': 200,
      },
      {
        'name': 'Vở ô ly Hồng Hà 200 trang',
        'price': 15000.0,
        'description':
            'Vở ô ly 200 trang, giấy trắng, bìa cứng đẹp, phù hợp cho học sinh.',
        'imageUrl': 'https://picsum.photos/seed/notebook/400/300',
        'category': 'Vở - Sổ',
        'stock': 150,
      },
      {
        'name': 'Thước kẻ nhựa 30cm',
        'price': 10000.0,
        'description': 'Thước kẻ nhựa trong suốt, có chia độ cm và mm rõ ràng.',
        'imageUrl': 'https://picsum.photos/seed/ruler/400/300',
        'category': 'Dụng cụ vẽ',
        'stock': 100,
      },
      {
        'name': 'Tẩy gôm Staedtler',
        'price': 8000.0,
        'description':
            'Tẩy nhẹ, sạch, không lem giấy. Dùng cho bút chì và mực.',
        'imageUrl': 'https://picsum.photos/seed/eraser/400/300',
        'category': 'Bút viết',
        'stock': 300,
      },
      {
        'name': 'Bút chì 2B Staedtler',
        'price': 6000.0,
        'description': 'Bút chì lõi đậm, dùng cho vẽ kỹ thuật và viết tay.',
        'imageUrl': 'https://picsum.photos/seed/pencil/400/300',
        'category': 'Bút viết',
        'stock': 250,
      },
      {
        'name': 'Compa vẽ kim loại',
        'price': 35000.0,
        'description':
            'Compa kim loại chắc chắn, dùng cho vẽ hình học, toán học.',
        'imageUrl': 'https://picsum.photos/seed/compass/400/300',
        'category': 'Dụng cụ vẽ',
        'stock': 80,
      },
      {
        'name': 'Máy tính Casio FX-580VN X',
        'price': 320000.0,
        'description':
            'Máy tính khoa học, hỗ trợ 552 chức năng, màn hình LCD sắc nét.',
        'imageUrl': 'https://picsum.photos/seed/calculator/400/300',
        'category': 'Thiết bị',
        'stock': 50,
      },
      {
        'name': 'Hộp bút nhựa đa năng',
        'price': 45000.0,
        'description':
            'Hộp bút 2 ngăn rộng rãi, chất liệu nhựa bền, màu sắc tươi sáng.',
        'imageUrl': 'https://picsum.photos/seed/pencilbox/400/300',
        'category': 'Phụ kiện',
        'stock': 120,
      },
      {
        'name': 'Kéo học sinh Maped',
        'price': 22000.0,
        'description':
            'Kéo học sinh an toàn, cắt sắc, tay cầm chống trơn trượt.',
        'imageUrl': 'https://picsum.photos/seed/scissors/400/300',
        'category': 'Dụng cụ',
        'stock': 90,
      },
      {
        'name': 'Balo học sinh chống thấm',
        'price': 380000.0,
        'description':
            'Balo thiết kế thông minh, nhiều ngăn, chống thấm nước, giảm tải lưng.',
        'imageUrl': 'https://picsum.photos/seed/backpack/400/300',
        'category': 'Túi - Balo',
        'stock': 40,
      },
      {
        'name': 'Giấy A4 Navigator 500 tờ',
        'price': 85000.0,
        'description':
            'Giấy A4 80gsm, trắng sáng, in rõ nét, phù hợp máy in và photocopy.',
        'imageUrl': 'https://picsum.photos/seed/paper/400/300',
        'category': 'Giấy tờ',
        'stock': 200,
      },
      {
        'name': 'Bộ màu nước 24 màu Sakura',
        'price': 95000.0,
        'description':
            'Bộ màu nước 24 màu sặc sỡ, không độc hại, phù hợp cho học sinh tiểu học.',
        'imageUrl': 'https://picsum.photos/seed/watercolor/400/300',
        'category': 'Dụng cụ vẽ',
        'stock': 60,
      },
    ];

    final batch = _db.batch();
    for (final data in sampleData) {
      final ref = _db.collection(_collection).doc();
      batch.set(ref, data);
    }
    await batch.commit();
  }
}
