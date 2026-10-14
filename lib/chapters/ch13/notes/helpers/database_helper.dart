import 'dart:io';

import 'package:flutter/foundation.dart'; // debugPrint
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

// ============================================================================
// DatabaseHelper — ศูนย์รวมตรรกะฐานข้อมูล (หัวข้อ 13.4 – 13.9)
//
// รวมของที่ตำราค่อย ๆ เพิ่มทีละหัวข้อไว้ในไฟล์เดียว:
//   13.4  Singleton + เปิดฐานข้อมูล       13.5  CREATE TABLE ใน onCreate
//   13.6  CRUD                            13.7  ใช้ Model (toMap/fromMap)
//   13.8  onUpgrade (เพิ่มคอลัมน์)         13.9  transaction + batch
//
// pubspec.yaml ต้องมี  sqflite · path · path_provider
// ============================================================================
class DatabaseHelper {
  static const _databaseName = 'MyNotes.db';

  // [คืออะไร] เลขเวอร์ชันของ "โครงสร้างตาราง" (schema) — ไม่ใช่เวอร์ชันแอป
  // [ทำไม]   openDatabase เทียบเลขที่บันทึกในไฟล์กับค่านี้ทุกครั้งที่เปิด:
  //            ไม่มีไฟล์            → เรียก onCreate
  //            เลขในไฟล์ < ค่านี้     → เรียก onUpgrade (ผู้ใช้เดิมที่อัปเดตแอป)
  // [ข้อสอบ] version 1 → 2 เพราะเพิ่มคอลัมน์ created_at · เพิ่มเลขทุกครั้งที่โครงสร้างเปลี่ยน
  static const _databaseVersion = 2;

  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  // [คืออะไร] รูปแบบที่ทำให้มีอินสแตนซ์ของคลาส "เพียงตัวเดียว" ทั้งแอป
  // [ทำไม]   (1) การเปิดไฟล์ฐานข้อมูลมีต้นทุน → เปิดครั้งเดียวใช้ตลอด
  //          (2) มีผู้ดูแล onCreate/onUpgrade ที่เดียว
  //          (3) SQLite เขียนได้ทีละรายการ หลายการเชื่อมต่อแย่งเขียน → "database is locked"
  // [อุปมา]  ห้องนิรภัยที่มีกุญแจดอกเดียว ถือโดยผู้จัดการคนเดียว
  // [ข้อเสีย] ตัวแปร static/global ทดสอบยาก (สลับเป็นของปลอมไม่ได้ง่าย)
  DatabaseHelper._privateConstructor(); // constructor ส่วนตัว: ภายนอกสร้างใหม่ไม่ได้
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // [คืออะไร] getter แบบ async: ยังไม่เปิด → เปิดให้ (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // [คืออะไร] ขอโฟลเดอร์เก็บข้อมูลแอปจากระบบปฏิบัติการ (path_provider)
    // [ทำไม]   มือถือใช้ sandbox: แอปเขียนไฟล์นอกพื้นที่ตัวเองไม่ได้ และโครงสร้างโฟลเดอร์
    //          Android/iOS ต่างกัน → ต้องถามระบบ ไม่ hard-code เส้นทางเอง
    // [ข้อควรระวัง] เลือก path วิธีใดแล้ว "ห้ามเปลี่ยนทีหลัง" หลังแอปถูกใช้งานจริง
    //          ไม่งั้น openDatabase สร้างไฟล์ว่างใหม่ ข้อมูลเดิมหายหมด
    // [ทางเลือก] getDatabasesPath() ของ sqflite เอง (แลป expense_tracker ใช้แบบนี้ ไม่ต้องใช้ path_provider)
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName); // join จากแพ็กเกจ path
    debugPrint('Database path: $path');

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate, // ผู้ใช้ใหม่ ยังไม่มีไฟล์
      onUpgrade: _onUpgrade, // ผู้ใช้เดิม ไฟล์มีเลขเวอร์ชันต่ำกว่า
    );
  }

  // ---------------------------------------------------------------------------
  // 13.5 สร้างตาราง
  // ---------------------------------------------------------------------------
  // [ข้อสอบ] _onCreate ต้องสร้างโครงสร้าง "ล่าสุด" เสมอ และต้องได้ผลเหมือนเครื่องที่ไล่
  //          onUpgrade มาถึงเวอร์ชันนี้ ถ้าสองทางได้ตารางไม่เหมือนกัน บั๊กจะเกิดกับผู้ใช้บางกลุ่ม
  //          (หาสาเหตุยากมาก)
  // [ข้อควรระวัง] onCreate ทำงาน "ครั้งเดียวตอนไฟล์ถูกสร้าง" แก้ SQL ที่นี่ไม่มีผลกับไฟล์เดิม
  //          ช่วงพัฒนาแก้ได้ด้วยการ uninstall แอป (แต่ของจริงคือลบข้อมูลผู้ใช้ → ใช้ onUpgrade)
  Future<void> _onCreate(Database db, int version) async {
    // [คืออะไร] db.execute รันคำสั่ง SQL ที่ไม่คืนข้อมูลแถว (CREATE/ALTER/DROP)
    // ชนิดข้อมูลที่ใช้: INTEGER→int · TEXT→String · REAL→double · BLOB→Uint8List
    //   PRIMARY KEY + AUTOINCREMENT : รหัสแถว ฐานข้อมูลสร้างให้เองและไม่ซ้ำ
    //   NOT NULL : ห้ามว่าง
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // 13.8 onUpgrade
  // ---------------------------------------------------------------------------
  // [อุปมา]  _onCreate = สร้างตึกบนที่ดินเปล่า (ทำได้ครั้งเดียว) · onUpgrade = ต่อเติมตึกที่มีคนอยู่แล้ว
  //          ทุบทิ้งสร้างใหม่ไม่ได้เพราะข้าวของ (ข้อมูลผู้ใช้) อยู่ข้างใน
  // [ข้อสอบ] กฎ 4 ข้อ:
  //   1) ใช้ if (oldVersion < N) เรียงต่อกัน — ไม่ใช้ == หรือ switch เพราะผู้ใช้บางคนข้ามเวอร์ชัน
  //      (เครื่องที่ข้ามจาก 1 → 3 ต้องผ่านทั้งขั้น 2 และ 3)
  //   2) ห้ามแก้ขั้นที่ปล่อยให้ผู้ใช้ไปแล้ว (มีเครื่องผ่านขั้นนั้นไปจริง)
  //   3) คอลัมน์ที่ ALTER เพิ่มจะเป็น NULL ในแถวเดิม → fromMap ต้องรับ null
  //   4) ลบ/เปลี่ยนชื่อคอลัมน์ทำได้จำกัด → สร้างตารางใหม่ + INSERT INTO ... SELECT + DROP + RENAME
  // [ข้อดี]   callback ทั้งสาม (onCreate/onUpgrade/…) ทำงานใน transaction — ล้มกลางทางไฟล์กลับสภาพเดิม
  // [วิธีทดสอบ] ติดตั้งรุ่น version 1 ใส่ข้อมูล → แก้เป็น 2 รันทับ "โดยไม่ถอนการติดตั้ง"
  //          แถวเดิมต้องอยู่ครบ และ created_at เป็น null
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
    }
    // เวอร์ชันถัดไปเพิ่ม `if (oldVersion < 3) { ... }` ต่อท้ายตรงนี้
  }

  // ---------------------------------------------------------------------------
  // 13.6 CRUD (ใช้ Model ตาม 13.7)
  // ---------------------------------------------------------------------------

  // Create — insert คืน "id ของแถวที่เพิ่ม"
  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  // Read — query คืน List<Map> แล้วแปลงเป็น List<Note>
  // [ข้อสอบ] พารามิเตอร์ของ query(): table · columns · where · whereArgs · groupBy · having ·
  //          orderBy · limit · offset
  Future<List<Note>> queryAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map(Note.fromMap).toList();
  }

  // ตัวอย่าง where + whereArgs
  // [ข้อสอบ] SQL Injection: ข้อความจากผู้ใช้/เครือข่าย ต้องเข้าทาง whereArgs (?) เท่านั้น
  //   อันตราย: db.rawQuery("SELECT * FROM notes WHERE title = '$keyword'")
  //            ถ้าพิมพ์ x' OR '1'='1 เงื่อนไขจะจริงทุกแถว (ข้อความผู้ใช้กลายเป็นส่วนของคำสั่ง)
  //   ปลอดภัย: SQLite เตรียมคำสั่งที่มี ? ก่อนโดยยังไม่รู้ค่า แล้วผูกค่าเป็น "ข้อมูล" ภายหลัง
  //            (ไม่ใช่ "ทำความสะอาด" ข้อความ — เครื่องหมาย ' ถูกเก็บลงไปตามจริง)
  Future<List<Note>> searchNotes(String keyword) async {
    final db = await database;
    final rows = await db.query(
      'notes',
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  // Update — คืน "จำนวนแถวที่ได้รับผลกระทบ"
  // [ข้อสอบ] กฎเหล็ก: update/delete ที่ไม่ใส่ where = ทำกับ "ทุกแถว" ตรวจ where + whereArgs เสมอ
  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete — คืนจำนวนแถวที่ถูกลบ
  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // 13.9 transaction + batch
  // ---------------------------------------------------------------------------
  // [คืออะไร] ทำหลายคำสั่งให้ "สำเร็จทั้งหมดหรือไม่เกิดขึ้นเลย" (Atomicity ของ ACID)
  // [ทำไม]   ถ้าลบข้อมูลเดิมแล้วแอปถูกปิดก่อนเพิ่มชุดใหม่ ผู้ใช้จะเหลือข้อมูลครึ่งเดียว
  //          ใน transaction: ล้มกลางทาง → rollback ข้อมูลเดิมยังอยู่ครบ
  // [ข้อสอบ] SQLite รับประกัน atomic ให้อัตโนมัติ "เฉพาะภายในคำสั่งเดียว"
  //          update สองครั้งแยกกันไม่ได้อยู่ใน transaction เดียวกัน (ต้องครอบด้วย transaction() เอง)
  // [ข้อสอบ] กับดักทำให้แอปค้าง: ในบล็อก transaction ต้องใช้ `txn` ทุกคำสั่ง
  //          ถ้าเผลอเรียก db.insert(...) หรือเมธอดอื่นที่ใช้ db ภายใน → คำสั่งนั้นรอ transaction จบ
  //          ขณะที่ transaction รอมัน = deadlock (วงล้อหมุนไม่มี error)
  Future<void> replaceAllNotes(List<Note> notes) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('notes'); // ใช้ txn ไม่ใช่ db!

      // [คืออะไร] batch รวมคำสั่งจำนวนมากส่งข้าม Dart→แพลตฟอร์ม "รอบเดียว"
      // [ข้อดี]   เร็วกว่าส่งทีละคำสั่งมากเมื่อมีหลายร้อยแถว
      final batch = txn.batch();
      for (final note in notes) {
        batch.insert('notes', note.toMap());
      }
      // noResult: true = ไม่ต้องการ id ของแต่ละแถว → เร็วขึ้นอีก
      await batch.commit(noResult: true);
    });
  }
}
