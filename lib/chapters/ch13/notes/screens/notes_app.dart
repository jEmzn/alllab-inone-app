import 'package:flutter/material.dart';

import 'notes_screen.dart';

// ============================================================================
// แลปบทที่ 13 (13.4 – 13.9): MyNotes — DatabaseHelper + CRUD + onUpgrade + transaction
//
// ไฟล์ในแลปนี้:
//   notes/helpers/database_helper.dart  ← หัวใจ: Singleton, onCreate, onUpgrade, CRUD, transaction
//   notes/models/note.dart              ← toMap / fromMap
//   notes/screens/notes_screen.dart     ← UI
//   notes/screens/notes_app.dart        ← (ไฟล์นี้) main.dart
// ============================================================================
//
// [คืออะไร] แอปนี้ไม่มี Provider — หน้าจอเรียก DatabaseHelper.instance ตรง ๆ แล้ว setState เอง
// [ทำไม]   แสดงสถาปัตยกรรมแบบ "Helper + setState" เทียบกับ "Provider ถือ DB" ของแลป expense_tracker
// [ข้อเสีย] ถ้ามีหลายหน้าจอใช้ข้อมูลชุดเดียวกัน ต้องคอยอ่านใหม่ทุกหน้า (ไม่มีใครแจ้งให้อัตโนมัติ)
class Ch13NotesApp extends StatelessWidget {
  const Ch13NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SQLite Lab',
      debugShowCheckedModeBanner: false,
      home: NotesScreen(),
    );
  }
}
