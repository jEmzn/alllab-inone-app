import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/my_transaction.dart';

// ============================================================================
// TransactionProvider — "ผู้จัดการ": ถือ state + คุยกับ SQLite เอง (กระบวนการที่ 2 – 6)
//
// อุปมาของตำรา (แผนกในบริษัท):
//   หน้าจอ/วิดเจ็ต  = พนักงานต้อนรับ  รับเรื่องผู้ใช้ + แสดงผล ไม่ลงมือจัดการข้อมูลเอง
//   TransactionProvider = ผู้จัดการ   รู้ตรรกะทั้งหมด สั่งห้องใต้ดิน (SQLite) เก็บ/เบิกเอกสาร
//                                       เสร็จแล้วถือข้อมูลล่าสุด + ประกาศผ่าน notifyListeners()
//   Consumer          = พนักงานที่ใส่หูฟัง ได้ยินแล้ววาดหน้าจอใหม่
// หลักการ = Separation of Concerns: หน้าจอไม่ต้องรู้ว่ามี SQL ในโลก
//
// สูตร 7 ขั้นเมื่อโจทย์สอบให้ entity มา (ใช้โครงเดียวกับไฟล์นี้):
//   1 Model    : ฟิลด์+ชนิด, id เป็น int?, toMap (ใส่ id เฉพาะเมื่อมีค่า), fromMap
//   2 Schema   : CREATE TABLE ชื่อคอลัมน์ตรงกับคีย์ใน toMap เป๊ะ + ชนิดตามตารางแปลง
//   3 Provider : _database, List<Model> _items, getter (สำเนา), _initDatabase
//   4 CRUD     : add / fetchAndSet / update / delete ทุกอันต้อง await _initDatabase()
//                แล้วเรียก fetchAndSet (หรือ notifyListeners) ปิดท้ายให้ UI อัปเดต
//   5 main     : ChangeNotifierProvider(create: => Provider()) เหนือ MaterialApp
//   6 List UI  : Consumer<Provider> + ListView.builder + ปุ่มลบ + ปุ่มเพิ่ม/แตะเพื่อแก้
//   7 Form UI  : Form + validator + บันทึก → context.read<...>().add/update → pop
// ข้อควรเช็กก่อนส่งงาน: where+whereArgs ใน update/delete · notifyListeners ครบ ·
//   ไม่ใช้ context.watch ใน onPressed · dispose controller · ชื่อคอลัมน์ตรงกันทุกที่
// ============================================================================
class TransactionProvider with ChangeNotifier {
  static const String _dbName = 'expenses.db';
  static const String _tableName = 'transactions';

  // [คืออะไร] ตัวเชื่อมต่อฐานข้อมูล · null = ยังไม่เปิด
  Database? _database;
  List<MyTransaction> _transactions = [];
  double _balance = 0;

  // [ทำไม]   คืน "สำเนา" ([...]) กันหน้าจอแก้ลิสต์ตรง ๆ โดยไม่ผ่านเมธอดของ provider
  // [ข้อเสีย] สร้างลิสต์ใหม่ทุกครั้งที่เรียก getter (ถูกสำหรับข้อมูลระดับนี้)
  List<MyTransaction> get transactions => [..._transactions];

  // ยอดคงเหลือ (รายรับ − รายจ่าย) — คำนวณใน "ฐานข้อมูล" ด้วย SUM (ความท้าทายข้อ 2)
  double get balance => _balance;

  // [คืออะไร] เรียกโหลดข้อมูลตั้งแต่ provider ถูกสร้าง
  // [ข้อสอบ] ใน constructor เรียก async ได้แต่ "รอไม่ได้" → UI ต้องรับมือช่วงที่ยังว่างอยู่
  //          (ที่นี่ Consumer เห็นลิสต์ว่างก่อน แล้ว notifyListeners ทำให้วาดใหม่เมื่อโหลดเสร็จ)
  TransactionProvider() {
    fetchAndSetTransactions();
  }

  // --- กระบวนการที่ 2: เปิดฐานข้อมูล + สร้างตาราง ---
  Future<void> _initDatabase() async {
    if (_database != null) return; // เปิดแล้วไม่ต้องเปิดซ้ำ
    try {
      // [คืออะไร] getDatabasesPath() ของ sqflite — โฟลเดอร์ฐานข้อมูลมาตรฐานของเครื่อง
      // [ข้อดี]   ไม่ต้องใช้ path_provider (แลปนี้ใช้ path เฉพาะ join ต่อชื่อไฟล์)
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          debugPrint('Creating table $_tableName...');
          // [ข้อสอบ] ชื่อคอลัมน์ต้องตรงกับคีย์ใน MyTransaction.toMap() ทุกตัว
          //          (date เก็บเป็น TEXT ISO-8601, type เก็บ .name เป็น TEXT, amount เป็น REAL)
          return db.execute(
            'CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title TEXT, amount REAL, date TEXT, type TEXT)',
          );
        },
      );
      debugPrint('Database initialized at $path');
    } catch (e) {
      // [ข้อเสีย] กลืน error ไว้แค่ print → เมธอดอื่นจึงต้องเช็ก `_database == null` ต่อ
      debugPrint('Error initializing database: $e');
    }
  }

  // --- กระบวนการที่ 3: Create ---
  // [คืออะไร] Future<void> + async: ทุกคำสั่งของ sqflite เป็น Future (ใช้ทักษะบทที่ 12)
  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
  ) async {
    await _initDatabase(); // รับประกันว่า DB พร้อมก่อนใช้
    if (_database == null) return;

    final newTransaction = MyTransaction(
      title: title,
      amount: amount,
      date: date,
      type: type,
    );
    // insert คืน id ของแถวใหม่
    final id = await _database!.insert(_tableName, newTransaction.toMap());
    debugPrint('Inserted transaction with id: $id');

    // อ่านใหม่จาก DB แล้วแจ้ง UI (เขียนแล้วอ่านซ้ำ = UI ตรงกับข้อมูลจริงเสมอ)
    await fetchAndSetTransactions();
  }

  // --- กระบวนการที่ 4: Read ---
  Future<void> fetchAndSetTransactions() async {
    await _initDatabase();
    if (_database == null) return;

    // orderBy 'date DESC' ได้ถูกลำดับเวลา เพราะ ISO-8601 เรียงตามตัวอักษร = เรียงตามเวลา
    final dataList = await _database!.query(_tableName, orderBy: 'date DESC');
    _transactions = dataList.map((item) => MyTransaction.fromMap(item)).toList();

    // ความท้าทายข้อ 2: คำนวณยอดรวมใน DB ด้วย SUM แทนวนบวกใน Dart
    // [คืออะไร] rawQuery รับ SQL ดิบ · CASE WHEN เลือกบวก/ลบตามประเภท
    // [ข้อดี]   แถวนับพัน → ให้ DB (ที่มีเครื่องมือเหมาะ) คิด ไม่ต้องดึงทุกแถวขึ้นมาวนบวก
    // [ข้อสอบ] ถ้าไม่มีแถวเลย SUM คืน NULL → ต้อง `?? 0`
    final result = await _database!.rawQuery(
      "SELECT SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) AS balance "
      'FROM $_tableName',
    );
    _balance = (result.first['balance'] as num?)?.toDouble() ?? 0;

    debugPrint('Fetched ${_transactions.length} transactions, balance=$_balance');
    notifyListeners(); // แจ้ง UI ให้วาดใหม่
  }

  // --- กระบวนการที่ 5: Update ---
  Future<void> updateTransaction(int id, MyTransaction newTransaction) async {
    await _initDatabase();
    if (_database == null) return;

    await _database!.update(
      _tableName,
      newTransaction.toMap(), // toMap ไม่ส่ง id ที่เป็น null จึงไม่ไปเปลี่ยนคีย์หลัก
      where: 'id = ?', // [ข้อสอบ] ลืม where = อัปเดตทุกแถว
      whereArgs: [id],
    );
    await fetchAndSetTransactions();
  }

  // --- กระบวนการที่ 6: Delete ---
  Future<void> deleteTransaction(int id) async {
    await _initDatabase();
    if (_database == null) return;

    await _database!.delete(
      _tableName,
      where: 'id = ?', // [ข้อสอบ] ลืม where = ลบทุกแถว!
      whereArgs: [id],
    );
    await fetchAndSetTransactions();
  }
}
