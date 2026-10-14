import 'package:flutter/material.dart';

import '../../core/lab.dart';
import '../../core/sqflite_guard.dart';
import 'exam_book/screens/exam_book_app.dart';
import 'expense/screens/expense_app.dart';
import 'notes/screens/notes_app.dart';
import 'todo_offline/screens/todo_offline_app.dart';

/// บทที่ 13 — SQLite (sqflite) · ทุกแลปห่อด้วย SqfliteGuard เพราะรันได้เฉพาะ Android/iOS
final LabChapter chapter13 = LabChapter(
  number: 13,
  title: 'Data Persistence ด้วย SQLite',
  subtitle: 'DatabaseHelper, CRUD, Model, onUpgrade, transaction, offline-first, '
      'Provider + SQLite (รูปแบบของข้อสอบเขียนโค้ด)',
  icon: Icons.storage,
  labs: [
    Lab(
      id: 'ch13-notes',
      title: 'MyNotes: DatabaseHelper + CRUD + onUpgrade + transaction (13.4–13.9)',
      goal:
          'Singleton DatabaseHelper, openDatabase/onCreate, CRUD ด้วย insert/query/update/delete, '
          'where + whereArgs (กัน SQL injection), Model toMap/fromMap, onUpgrade (v1→v2), transaction + batch',
      tryThis: [
        'เพิ่มโน้ต → ดู Debug Console: Inserted row id · ปิดแอปเปิดใหม่ ข้อมูลยังอยู่ (persistence)',
        'กดดินสอเพื่อแก้ (ปุ่มเปลี่ยนเป็น Update Note) · กดถังขยะเพื่อลบ',
        'กด "แทนที่ด้วย 100 ตัวอย่าง" ดูเวลาที่ใช้ใน Console (batch ใน transaction)',
        'ในโค้ด database_helper.dart: อ่านคอมเมนต์ของ _onCreate vs _onUpgrade และกฎ if (oldVersion < N)',
      ],
      files: [
        'lib/chapters/ch13/notes/helpers/database_helper.dart',
        'lib/chapters/ch13/notes/models/note.dart',
        'lib/chapters/ch13/notes/screens/notes_screen.dart',
        'lib/chapters/ch13/notes/screens/notes_app.dart',
      ],
      entry: (context) => const SqfliteGuard(child: Ch13NotesApp()),
    ),
    Lab(
      id: 'ch13-todo-offline',
      title: 'todo_offline: SQLite + เครือข่าย + Provider (13.10)',
      goal:
          'Repository pattern และ offline-first: หน้าจออ่านจาก SQLite เท่านั้น, เครือข่ายเขียนทับ DB ใน transaction, '
          'สถานะหน้าจอ 4 แบบ (ข้อมูล/กำลังรีเฟรช/ผิดพลาด/เวลาซิงก์)',
      tryThis: [
        'โหมด "จำลอง: สำเร็จ" → วงล้อ → รายการ 200 รายการ (เขียนลง SQLite แล้ว)',
        'ออกจากแลป เปลี่ยนโหมดเป็น "ไม่มีสัญญาณ" แล้วเข้าใหม่ → เห็นรายการเดิมทันที + แถบข้อความ',
        'เปลี่ยนโหมดกลับเป็นสำเร็จแล้วกด "ลองใหม่" → แถบบาง ๆ ใต้ AppBar แทนการเปลี่ยนทั้งหน้าเป็นวงล้อ',
      ],
      files: [
        'lib/chapters/ch13/todo_offline/repositories/todo_repository.dart',
        'lib/chapters/ch13/todo_offline/providers/todo_provider.dart',
        'lib/chapters/ch13/todo_offline/screens/todo_list_screen.dart',
        'lib/chapters/ch13/todo_offline/data/app_database.dart',
        'lib/chapters/ch13/todo_offline/screens/todo_offline_app.dart',
        'lib/chapters/ch12/models/todo.dart',
      ],
      entry: (context) => const SqfliteGuard(child: Ch13TodoOfflineApp()),
    ),
    Lab(
      id: 'ch13-expense',
      title: '★ expense_tracker_provider: Provider ถือ SQLite (ปฏิบัติการหลัก + การบ้านเฉลย)',
      goal:
          'โครงที่ข้อสอบเขียนโค้ดใช้: Model (toMap/fromMap) + Provider ที่เปิด DB และทำ CRUD เอง + '
          'หน้ารายการ (Consumer) + ฟอร์มเพิ่ม/แก้ไข (Form/validator/DatePicker) · '
          'อ่านสูตร 7 ขั้นในคอมเมนต์ของ transaction_provider.dart',
      tryThis: [
        'กด + เพิ่มรายการรายรับ/รายจ่าย (เลือกวันที่ได้) → ยอดคงเหลือเปลี่ยน (คำนวณด้วย SUM ใน SQLite)',
        'แตะรายการเพื่อแก้ไข · กดถังขยะเพื่อลบ · ปิดแอปแล้วเปิดใหม่ ข้อมูลยังอยู่',
        'ลองใส่จำนวนเงินว่าง/ตัวอักษร/0 เพื่อดู validator',
        'อ่าน transaction_provider.dart ทั้งไฟล์ แล้วลองเขียนใหม่เองจากกระดาษเปล่า',
      ],
      files: [
        'lib/chapters/ch13/expense/providers/transaction_provider.dart',
        'lib/chapters/ch13/expense/models/my_transaction.dart',
        'lib/chapters/ch13/expense/screens/transaction_list_screen.dart',
        'lib/chapters/ch13/expense/screens/add_edit_transaction_screen.dart',
        'lib/chapters/ch13/expense/screens/expense_app.dart',
      ],
      entry: (context) => const SqfliteGuard(child: Ch13ExpenseApp()),
    ),
    Lab(
      id: 'ch13-exam-book',
      title: '★ Exam Workshop: Book — ใช้สูตรเดียวกับ entity ใหม่',
      goal:
          'โจทย์จำลองแบบข้อสอบ "ให้ entity มา → ออกแบบ model/provider/UI ให้ CRUD ได้": '
          'Book มี double, enum, bool, DateTime ครบทุกชนิดที่ต้องแปลงให้ SQLite + ค้นหาด้วย where/whereArgs',
      tryThis: [
        'เพิ่มหนังสือหลายเล่ม · ติ๊กช่อง "อ่านแล้ว" จากหน้ารายการ (copyWith → update)',
        'พิมพ์ในช่องค้นหา → กรองด้วย SQL LIKE ? · ปัดแถวไปทางซ้ายเพื่อลบ',
        'เปิด book.dart: ดูว่าฟิลด์แต่ละชนิดแปลงเป็นอะไรใน toMap/fromMap',
        'ฝึก: ปิดไฟล์ทั้งหมด แล้วเขียน entity อื่น (เช่น Student) จากสูตรเดียวกัน',
      ],
      files: [
        'lib/chapters/ch13/exam_book/models/book.dart',
        'lib/chapters/ch13/exam_book/providers/book_provider.dart',
        'lib/chapters/ch13/exam_book/screens/book_list_screen.dart',
        'lib/chapters/ch13/exam_book/screens/book_form_screen.dart',
        'lib/chapters/ch13/exam_book/screens/exam_book_app.dart',
      ],
      entry: (context) => const SqfliteGuard(child: Ch13ExamBookApp()),
    ),
  ],
);
