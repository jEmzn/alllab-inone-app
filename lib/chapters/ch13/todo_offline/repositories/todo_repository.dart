import 'package:sqflite/sqflite.dart';

import '../../../ch12/models/todo.dart';
import '../../../ch12/services/api_service.dart';

// ============================================================================
// TodoRepository — ชั้นกลางระหว่าง Provider กับแหล่งข้อมูล 2 แห่ง (หัวข้อ 13.10)
//
// [คืออะไร] Repository pattern: ชั้นที่รู้จักทั้ง "เครือข่าย" (fetchTodos จากบท 12)
//          และ "ฐานข้อมูลในเครื่อง" (SQLite) · Provider รู้จักแต่ repository
// [ทำไม]   ถ้าใส่ตรรกะนี้ใน fetchTodos() ชั้นเครือข่ายจะต้องรู้เรื่องฐานข้อมูล
//          ถ้าใส่ใน provider โค้ดจะปนกันจนทดสอบแยกส่วนไม่ได้
//
// แนวคิด offline-first (local-first):
//   - "แหล่งความจริงของหน้าจอ" = ฐานข้อมูลในเครื่อง · หน้าจอ "อ่านจาก DB เท่านั้น"
//   - ข้อมูลจากเครือข่ายมีหน้าที่เดียวคือ "เขียนทับลง DB"
//   [ข้อดี] เปิดแอปมีข้อมูลโชว์ทันทีแม้ไม่มีสัญญาณ · ไม่มีจังหวะที่สองหน้าจอเห็นข้อมูลคนละชุด
//   [ข้อเสีย] ถ้าผู้ใช้แก้ข้อมูลในเครื่องตอนออฟไลน์ ต้องคิดเรื่องส่งกลับ/ชนกับคนอื่น
//            (conflict resolution) — นอกขอบเขตบทนี้
//   DB ในเครื่อง "ไม่ได้มาแทนเซิร์ฟเวอร์" แต่เป็นกันชนระหว่างผู้ใช้กับเครือข่าย
// ============================================================================
class TodoRepository {
  TodoRepository(this._db);

  // [คืออะไร] รับ Database ผ่าน constructor (ไม่เปิดเอง) — ดู app_database.dart
  final Database _db;

  // อ่านชุดที่เก็บไว้ในเครื่อง ได้ทันทีแม้ไม่มีสัญญาณ
  Future<List<Todo>> readCached() async {
    final rows = await _db.query('todos', orderBy: 'id');
    return rows.map(Todo.fromMap).toList();
  }

  // ดึงชุดใหม่ → เขียนทับในเครื่อง → คืนสิ่งที่อยู่ในเครื่อง
  Future<List<Todo>> refresh() async {
    // 1) ดึงจากเครือข่ายก่อน · ถ้าล้มเหลว (throw ApiException) บรรทัดถัดไปไม่ทำงาน
    //    → "ไม่แตะฐานข้อมูลเลย" ข้อมูลเดิมจึงอยู่ครบ
    final fresh = await fetchTodos(); // ชั้นเครือข่ายจาก 12.6

    // 2) เขียนทับด้วย transaction เดียว (13.9)
    // [ทำไม]   ลบชุดเดิมแล้วแอปถูกปิดก่อนเพิ่มชุดใหม่ = ข้อมูลหายครึ่งเดียว
    //          ใน transaction ล้มกลางทาง → rollback ข้อมูลเดิมคืนมาครบ
    await _db.transaction((txn) async {
      await txn.delete('todos'); // ใช้ txn ทุกคำสั่ง ห้ามใช้ _db ในบล็อกนี้
      final batch = txn.batch();
      for (final todo in fresh) {
        batch.insert('todos', todo.toMap());
      }
      await batch.commit(noResult: true);
    });

    // 3) อ่านกลับจาก DB เสมอ (ไม่คืน fresh ตรง ๆ) → หน้าจอเห็นเฉพาะสิ่งที่อยู่ใน DB
    return readCached();
  }
}
