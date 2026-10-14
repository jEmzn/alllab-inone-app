import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'screens/navigate_app.dart';

/// บทที่ 9 — ปฏิบัติการ: การนำทางระหว่างหน้าจอ (navigate_route)
final LabChapter chapter09 = LabChapter(
  number: 9,
  title: 'การนำทางระหว่างหน้าจอ',
  subtitle: 'ปฏิบัติการ navigate_route: push/pop, ส่งข้อมูลไป-กลับ, named routes, PopScope',
  icon: Icons.alt_route,
  labs: [
    Lab(
      id: 'ch09-navigate-route',
      title: 'navigate_route (แบบฝึกหัด 1–5 + ความท้าทาย 1–3)',
      goal:
          'เข้าใจ route stack ของ Navigator, การส่งข้อมูลไป (constructor / arguments) และกลับ (pop result), '
          'named routes, onGenerateRoute และการจัดการ stack (pushReplacement, pushAndRemoveUntil, PopScope)',
      tryThis: [
        'กดปุ่มแต่ละแบบฝึกหัดจากบนลงล่าง แล้วเทียบวิธีส่งข้อมูล',
        'แบบฝึกหัด 3: กด "ย้อนกลับ" ในหน้า → ได้ผลลัพธ์ · ลองใช้ลูกศร AppBar แทน → ได้ null',
        'ความท้าทาย 1: กดปุ่ม "ไม่ส่ง arguments" แล้วดูหน้า "ไม่พบหน้า" (onUnknownRoute)',
        'ความท้าทาย 2: พิมพ์ข้อความ แล้วกดลูกศรย้อนกลับ → dialog ถามก่อนทิ้ง',
        'ความท้าทาย 3: ล็อกอิน → โปรไฟล์ → ออกจากระบบ แล้วกดย้อนกลับ ดูว่าเหลือหน้าอะไร',
      ],
      files: [
        'lib/chapters/ch09/screens/home_screen.dart',
        'lib/chapters/ch09/screens/detail_screen.dart',
        'lib/chapters/ch09/screens/named_detail_screen.dart',
        'lib/chapters/ch09/screens/navigate_app.dart',
        'lib/chapters/ch09/screens/challenge_screens.dart',
      ],
      entry: (context) => const Ch09LabApp(),
    ),
  ],
);
