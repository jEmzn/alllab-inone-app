import 'package:flutter/material.dart';

// ============================================================================
// NamedDetailScreen — แบบฝึกหัด 4-5: หน้าที่ถูกเรียกด้วย named route + arguments
// ============================================================================
class NamedDetailScreen extends StatelessWidget {
  // [คืออะไร] ชื่อ route ของหน้านี้ — ลงทะเบียนใน MaterialApp.routes (navigate_app.dart)
  static const routeName = '/detail';

  const NamedDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] ดึง arguments ที่ส่งมากับ pushNamed จาก "route ของหน้านี้"
    // [ทำไม]   named route ส่งข้อมูลผ่าน constructor ไม่ได้ (routes map สร้างหน้าแบบไม่มีพารามิเตอร์)
    // [ข้อสอบ] ต้องอ่านใน build() ไม่ใช่ initState เพราะ ModalRoute.of(context) "สมัครรับ"
    //          การเปลี่ยนแปลงของ route ซึ่งต้องใช้ context ที่พร้อมแล้ว
    // [ข้อเสีย] `as Map<String, String>?` เป็น cast ตอนรัน — ผู้เรียกส่งชนิดอื่นมา
    //          = แอปพัง (คอมไพเลอร์ช่วยไม่ได้) → ความท้าทายข้อ 1 จึงแก้ด้วยคลาส + onGenerateRoute
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    // [ทำไม] `??` ให้ค่าสำรอง กันกรณี pushNamed โดยไม่ส่ง arguments (args เป็น null)
    final String itemId = args?['id'] ?? 'ไม่มี ID';
    final String pageTitle = args?['title'] ?? 'รายละเอียด';

    return Scaffold(
      appBar: AppBar(title: Text('ไอเท็ม: $itemId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ได้รับ: $pageTitle'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ย้อนกลับ'),
            ),
          ],
        ),
      ),
    );
  }
}
