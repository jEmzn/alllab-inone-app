import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// ============================================================================
// app_database.dart — เปิดฐานข้อมูล (13.10.1 ขั้นตอนที่ 4)
//
// [คืออะไร] ฟังก์ชันเดียวแทนคลาส DatabaseHelper (แบบ Singleton ของ 13.4) เพื่อให้สั้นลง
// [ทำไม]   หลักการเหมือนกัน: เปิดไฟล์ "ครั้งเดียว" แล้วส่งอ็อบเจกต์ Database ตัวเดียวกัน
//          ให้ทุกส่วนของแอป (ผ่าน constructor — dependency injection)
// [ข้อดี]   ทดสอบง่ายกว่า Singleton: ส่ง Database ปลอม/in-memory เข้า repository ได้
// [ข้อเสีย] ผู้เรียกต้องจำว่าห้ามเปิดซ้ำหลายครั้ง (ที่นี่ main เรียกครั้งเดียว)
// ============================================================================
Future<Database> openAppDatabase() async {
  final path = join(await getDatabasesPath(), 'todos.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      // [ข้อสอบ] id ไม่มี AUTOINCREMENT เพราะค่า id "มาจากเซิร์ฟเวอร์" (เรากำหนดเอง)
      //          ถ้าเป็น INTEGER PRIMARY KEY เฉย ๆ SQLite ยังสร้างเลขให้ได้เมื่อไม่ส่ง id
      //          แต่ที่นี่เราส่ง id จากเซิร์ฟเวอร์ทุกครั้ง
      return db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          completed INTEGER NOT NULL
        )
      ''');
    },
  );
}
