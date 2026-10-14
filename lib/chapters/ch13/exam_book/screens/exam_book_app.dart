import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import 'book_list_screen.dart';

// ============================================================================
// ขั้น 5 ของสูตร: ประกอบทุกอย่าง (main.dart)
//   void main() => runApp(ChangeNotifierProvider(create: (_) => BookProvider(), child: const MyApp()));
//   วาง Provider "เหนือ" MaterialApp เพื่อให้ทุกหน้าที่ถูก push เข้าถึงได้
// ============================================================================
//
// [คืออะไร] ChangeNotifierProvider(create: ...) สร้าง BookProvider หนึ่งอินสแตนซ์ให้ทุกหน้าใต้มัน
// [ทำไม]   create เป็นแบบ lazy — BookProvider() ถูกสร้าง (และเปิด DB ใน constructor) ตอนมี
//          วิดเจ็ตขอใช้ครั้งแรก · provider จะถูก dispose ให้เองเมื่อออกจาก tree
// [ข้อสอบ] ต้องเป็น "ลูกหลานของ" provider ถึง context.read/watch ได้ — วางไว้เหนือ MaterialApp
class Ch13ExamBookApp extends StatelessWidget {
  const Ch13ExamBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: const MaterialApp(
        title: 'Book Shelf',
        debugShowCheckedModeBanner: false,
        home: BookListScreen(),
      ),
    );
  }
}
