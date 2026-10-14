// ============================================================================
// Note — Model class ของตาราง notes (หัวข้อ 13.7 + 13.8)
//
// [คืออะไร] คลาส Dart ที่แทน "หนึ่งแถว" ของตาราง notes
// [ทำไม]   ปัญหา "Object-Relational Impedance Mismatch": Dart คิดเป็นอ็อบเจกต์/ชนิดข้อมูล
//          ส่วน SQL คิดเป็นตาราง/แถว/คอลัมน์ ชนิดไม่กี่แบบ → ต้องมี "ล่าม" แปลสองทาง
//            toMap()   : อ็อบเจกต์ → Map ที่ sqflite เอาไปหยอดลงคอลัมน์ (เหมือนถอดตู้ใส่กล่อง)
//            fromMap() : แถวที่อ่านได้ (Map) → อ็อบเจกต์ (เหมือนประกอบตู้กลับ)
// [ข้อดี]   พิมพ์ชื่อฟิลด์ผิด (note.tilte) → รู้ตั้งแต่เขียนโค้ด ไม่ใช่ตอนรัน
//          (เทียบกับ Map ดิบ note['tilte'] ที่คอมไพเลอร์ไม่เตือน)
// ============================================================================
class Note {
  // [คืออะไร] id เป็น int? (null ได้) — null = ยังไม่เคยบันทึก ฐานข้อมูลเป็นผู้กำหนดตอน insert
  final int? id;
  final String title;
  final String content;

  // [คืออะไร] คอลัมน์ที่เพิ่มด้วย onUpgrade (version 2) — เป็น nullable
  // [ทำไม]   ALTER TABLE ... ADD COLUMN ทำให้แถวเดิมทั้งหมดมีค่า NULL ในคอลัมน์ใหม่
  //          fromMap จึงต้องรับมือ null เสมอ
  final DateTime? createdAt;

  const Note({this.id, required this.title, required this.content, this.createdAt});

  Map<String, Object?> toMap() {
    return {
      // [ข้อสอบ] ใส่ id เฉพาะเมื่อมีค่า! ถ้าใส่ 'id': null ทุกครั้ง
      //   - insert : ใช้ได้ (SQLite สร้างเลขให้) แต่
      //   - update : กลายเป็นสั่งเปลี่ยนคีย์หลักให้เป็น null → SQLite ปฏิเสธ (datatype mismatch)
      //   `if (id != null)` ทำให้ toMap() ตัวเดียวใช้ได้ทั้ง insert และ update
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      // DateTime ไม่มีใน SQLite → เก็บเป็น TEXT ด้วย toIso8601String()
      // [ข้อดี] อ่านง่ายเมื่อเปิดไฟล์ และเรียงตามตัวอักษรได้ถูกลำดับเวลา
      // [ทางเลือก] INTEGER ด้วย millisecondsSinceEpoch เปรียบเทียบเร็วกว่า — เลือกแบบเดียวทั้งแอป
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // [คืออะไร] factory constructor สร้างอ็อบเจกต์จากแถว
  // [ข้อสอบ] Map ที่ได้จาก query() "อ่านอย่างเดียว" แก้ค่าในนั้นตรง ๆ จะ error
  //          → แปลงเป็นอ็อบเจกต์ทันทีที่อ่านขึ้นมา
  factory Note.fromMap(Map<String, Object?> map) {
    final created = map['created_at'] as String?;
    return Note(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: created == null ? null : DateTime.parse(created),
    );
  }
}
