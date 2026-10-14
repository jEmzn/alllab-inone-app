import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/book.dart';

// ============================================================================
// BookProvider — ขั้น 2-4 ของสูตร: Schema + Provider + CRUD (+ ค้นหา)
//
// เทียบกับ TransactionProvider ของแลป expense_tracker มี 3 จุดที่ปรับให้ "แข็งแรงขึ้น"
// (ใช้แบบไหนก็ได้ในข้อสอบ — แบบ expense ตามตำราก็ถูกต้อง):
//   (1) เปิด DB ด้วย getter เดียว `_database` ที่ cache Future ไว้ → เรียกพร้อมกันหลายที่
//       ก็เปิดครั้งเดียว (ไม่ต้องมี `if (_database == null) return;` ซ้ำทุกเมธอด)
//   (2) มีสถานะ _isLoading (บท 12) ให้ UI แยก "กำลังโหลด" ออกจาก "ไม่มีข้อมูล"
//   (3) ค้นหาด้วย where + whereArgs (กัน SQL injection)
// ============================================================================
class BookProvider extends ChangeNotifier {
  static const _tableName = 'books';

  // [คืออะไร] cache "Future ของการเปิดฐานข้อมูล" แทน cache ตัว Database
  // [ทำไม]   ถ้ามีสองที่เรียก `await _database` ตอน DB ยังไม่เปิด จะได้ Future ตัวเดียวกัน
  //          → openDatabase ถูกเรียกครั้งเดียว (ป้องกัน race ที่แบบ `if (_db == null)` มี)
  Future<Database>? _opening;
  Future<Database> get _database => _opening ??= _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'books.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // [ข้อสอบ] ชื่อคอลัมน์ตรงกับ Book.toMap() ทุกตัว · ชนิดตามตารางแปลง:
        //   double→REAL · enum→TEXT · bool→INTEGER · DateTime→TEXT
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT NOT NULL,
            price REAL NOT NULL,
            genre TEXT NOT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            added_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  List<Book> _books = [];
  bool _isLoading = true;
  String _query = '';

  List<Book> get books => List.unmodifiable(_books);
  bool get isLoading => _isLoading;
  String get query => _query;

  BookProvider() {
    load();
  }

  // --- Read (พร้อมตัวกรองค้นหา) ---
  Future<void> load() async {
    final db = await _database;
    final rows = await db.query(
      _tableName,
      // [ข้อสอบ] where/whereArgs เป็น null ได้ทั้งคู่ = ไม่กรอง (ดึงทุกแถว)
      where: _query.isEmpty ? null : 'title LIKE ?',
      whereArgs: _query.isEmpty ? null : ['%$_query%'], // ค่าจากผู้ใช้ต้องเข้าทาง whereArgs เท่านั้น
      orderBy: 'added_at DESC',
    );
    _books = rows.map(Book.fromMap).toList();
    _isLoading = false;
    notifyListeners();
  }

  // ค้นหา: เก็บคำค้นแล้วโหลดใหม่ (ใช้ SQL กรองใน DB ไม่ใช่กรองใน Dart)
  Future<void> search(String query) async {
    _query = query.trim();
    await load();
  }

  // --- Create ---
  Future<void> addBook(Book book) async {
    final db = await _database;
    await db.insert(_tableName, book.toMap());
    await load();
  }

  // --- Update ---
  Future<void> updateBook(Book book) async {
    final db = await _database;
    await db.update(
      _tableName,
      book.toMap(),
      where: 'id = ?', // ลืม where = อัปเดตทุกแถว!
      whereArgs: [book.id],
    );
    await load();
  }

  // ติ๊ก "อ่านแล้ว" จากหน้ารายการ: ใช้ copyWith แล้วส่งเข้า update เส้นเดียวกัน
  Future<void> toggleRead(Book book) => updateBook(book.copyWith(isRead: !book.isRead));

  // --- Delete ---
  Future<void> deleteBook(int id) async {
    final db = await _database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]); // ลืม where = ลบทุกแถว!
    await load();
  }
}
