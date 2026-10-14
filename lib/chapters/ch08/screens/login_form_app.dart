import 'package:flutter/material.dart';

import 'login_form_screen.dart';

// ============================================================================
// แลปบทที่ 8: การสร้างและตรวจสอบความถูกต้องของฟอร์ม  (ไฟล์นี้ = main.dart)
//
// ไฟล์ในแลปนี้:
//   login_form_app.dart     ← (ไฟล์นี้) ตัวห่อแอป
//   login_form_screen.dart  ← หน้าฟอร์มล็อกอินฉบับสมบูรณ์ (แบบฝึกหัด 1-5)
//
// ภาพรวมที่ต้องเข้าใจ:
//   Form ห่อ TextFormField หลายช่อง → ถือ GlobalKey<FormState> ไว้สั่งงาน
//     validate()  เรียก validator ของทุกช่อง → true/false และโชว์ error ใต้ช่อง
//     save()      เรียก onSaved ของทุกช่อง   → เก็บค่าไปไว้ที่ตัวแปรของเรา
// ============================================================================

// [คืออะไร] MyApp ของแลป: ตั้งหน้าแรกเป็นฟอร์ม
// [ทำไม]   ฟอร์มเป็นหน้าจอหนึ่งหน้า จึงแยกเป็นคลาสของตัวเอง (login_form_screen.dart)
//          แล้ว main แค่ชี้ไปที่มันผ่าน home:
// [จำเป็น?] debugShowCheckedModeBanner: false เป็นแค่เรื่องความสวยงาม ไม่จำเป็น
class Ch08LabApp extends StatelessWidget {
  const Ch08LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginFormScreen(),
    );
  }
}
