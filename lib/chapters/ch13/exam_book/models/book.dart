// ============================================================================
// EXAM WORKSHOP — โจทย์จำลอง: "ระบบจัดการหนังสือในห้องสมุดส่วนตัว"
//
//   โจทย์ (สมมติว่าข้อสอบให้มาแค่นี้):
//     entity Book ประกอบด้วย  ชื่อหนังสือ, ผู้แต่ง, ราคา, หมวด (นิยาย/วิชาการ/การ์ตูน),
//     อ่านแล้วหรือยัง, วันที่เพิ่ม
//     ให้ออกแบบ model, provider, UI ให้แอป CRUD กับ SQLite ได้ถูกต้อง
//     (+ ค้นหาตามชื่อ, ติ๊กว่าอ่านแล้วได้จากหน้ารายการ)
//
// วิธีใช้แลปนี้: อ่านสูตร 7 ขั้นใน transaction_provider.dart (แลป expense_tracker) แล้วดูว่า
// "โครงเดียวกัน" ถูกนำมาใช้กับ entity ใหม่อย่างไร โดยแตกต่างเฉพาะ "ส่วนที่ entity กำหนด":
//
//   ขั้น 1 Model   : ฟิลด์ชนิดต่าง ๆ → ต้องตัดสินใจวิธีแปลงให้ครบทุกชนิด (ไฟล์นี้)
//   ขั้น 2 Schema  : CREATE TABLE ชื่อคอลัมน์ = คีย์ใน toMap  (book_provider.dart)
//   ขั้น 3-4       : Provider + CRUD (ไฟล์เดียวกัน)
//   ขั้น 5         : ChangeNotifierProvider (exam_book_app.dart)
//   ขั้น 6-7       : UI รายการ + ฟอร์ม (book_list_screen.dart, book_form_screen.dart)
// ============================================================================

// [ข้อสอบ] enum เก็บเป็น TEXT ด้วย .name · อ่านกลับด้วย values.byName
enum Genre { novel, academic, comic }

class Book {
  final int? id; // null = ยังไม่บันทึก
  final String title;
  final String author;
  final double price;
  final Genre genre;
  final bool isRead;
  final DateTime addedAt;

  const Book({
    this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.genre,
    required this.isRead,
    required this.addedAt,
  });

  // [คืออะไร] copyWith : สร้างสำเนาที่เปลี่ยนเฉพาะบางฟิลด์
  // [ทำไม]   ฟิลด์เป็น final (immutable) แก้ตรง ๆ ไม่ได้ · ใช้ตอนติ๊ก "อ่านแล้ว" ที่หน้ารายการ
  //          (ส่ง Book เดิม + isRead ใหม่ไป update) — สะดวกกว่าเขียนทุกฟิลด์ใหม่
  // [จำเป็น?] ไม่จำเป็น (เขียน Book(...) ใหม่ทุกฟิลด์ก็ได้) แต่ลดโค้ดซ้ำและลดโอกาสลืมฟิลด์
  Book copyWith({
    String? title,
    String? author,
    double? price,
    Genre? genre,
    bool? isRead,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      genre: genre ?? this.genre,
      isRead: isRead ?? this.isRead,
      addedAt: addedAt,
    );
  }

  // ชื่อคีย์ = ชื่อคอลัมน์ในตาราง books (ต้องตรงกันเป๊ะ)
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id, // ห้ามส่ง null id (insert ไม่เป็นไร แต่ update พัง)
      'title': title,
      'author': author,
      'price': price, // double → REAL
      'genre': genre.name, // enum → TEXT
      'is_read': isRead ? 1 : 0, // bool → INTEGER (SQLite ไม่มี boolean)
      'added_at': addedAt.toIso8601String(), // DateTime → TEXT
    };
  }

  factory Book.fromMap(Map<String, Object?> map) {
    return Book(
      id: map['id'] as int,
      title: map['title'] as String,
      author: map['author'] as String,
      price: (map['price'] as num).toDouble(),
      genre: Genre.values.byName(map['genre'] as String),
      isRead: map['is_read'] == 1,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }
}
