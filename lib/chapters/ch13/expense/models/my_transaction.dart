// ============================================================================
// MyTransaction — Model ของแลป expense_tracker (กระบวนการที่ 2)
//
// ขั้นที่ 1 ของสูตรเขียนแอป CRUD เมื่อโจทย์ให้ "entity" มา:  เขียน Model ก่อนเสมอ
//   1) ฟิลด์ทั้งหมด + ชนิด Dart      2) id เป็น int? (null = ยังไม่บันทึก)
//   3) toMap()  4) factory fromMap()  — แปลงชนิดที่ SQLite ไม่มี ให้ตกลงที่สองเมธอดนี้ "จุดเดียว"
// ============================================================================

// [คืออะไร] enum ประเภทรายการ
// [ทำไม]   ปลอดภัยกว่าใช้ String 'income'/'expense' ลอย ๆ (พิมพ์ผิดไม่ได้ + switch ครบกรณี)
enum TransactionType { income, expense }

// [ข้อสอบ] ทำไมชื่อ MyTransaction ไม่ใช่ Transaction?
//   `Transaction` เป็นชื่อคลาสที่มีอยู่แล้วในแพ็กเกจ sqflite (transaction ของฐานข้อมูล, 13.9)
//   ถ้าตั้งชื่อชนกัน List<Transaction> จะคอมไพล์ไม่ผ่าน/สับสนชนิด
class MyTransaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  MyTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  // ตารางที่คู่กัน (ดู transaction_provider.dart):
  //   id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, type TEXT
  //
  // ตารางการแปลงชนิด Dart ↔ SQLite (จำให้ได้ ข้อสอบเขียนโค้ดต้องใช้):
  //   int      ↔ INTEGER                  String  ↔ TEXT          double ↔ REAL
  //   bool     ↔ INTEGER (1/0)            ← SQLite ไม่มี boolean
  //   DateTime ↔ TEXT (toIso8601String)   ← SQLite ไม่มีชนิดวันที่
  //   enum     ↔ TEXT (.name)             ← ห้ามใช้ .index (แทรกค่าใหม่กลาง enum ข้อมูลเก่าจะชี้ผิดค่า)
  Map<String, dynamic> toMap() {
    return {
      // [ข้อสอบ] ห้ามส่ง id ที่เป็น null เข้าไปใน UPDATE (ดู note.dart ที่อธิบายไว้ละเอียด)
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name, // เก็บเป็น 'income' หรือ 'expense'
    };
  }

  factory MyTransaction.fromMap(Map<String, dynamic> map) {
    return MyTransaction(
      id: map['id'] as int,
      title: map['title'] as String,
      // [ทำไม] REAL อ่านกลับมาเป็น double ปกติ แต่แถวที่เคยบันทึกเป็นจำนวนเต็มอาจกลับมาเป็น int
      //        แปลงผ่าน num เพื่อรองรับทั้งสองกรณี (as double ตรง ๆ จะ error ถ้าเป็น int)
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      // values.byName ตรงข้ามกับ .name · ถ้าชื่อไม่ตรงจะ throw
      type: TransactionType.values.byName(map['type'] as String),
    );
  }
}
