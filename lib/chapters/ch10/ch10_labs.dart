import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'screens/provider_counter_app.dart';
import 'screens/setstate_counter_app.dart';

/// บทที่ 10 — ปฏิบัติการ: Refactor ตัวนับด้วย Provider
final LabChapter chapter10 = LabChapter(
  number: 10,
  title: 'Provider เบื้องต้น',
  subtitle: 'ปฏิบัติการ: Refactor ตัวนับจาก setState ไปเป็น Provider',
  icon: Icons.hub,
  labs: [
    Lab(
      id: 'ch10-before',
      title: 'ก่อน refactor: ตัวนับด้วย setState',
      goal: 'จุดเริ่มต้นของแลป — ใช้เทียบกับเวอร์ชัน Provider ว่าอะไรย้ายไปไหน',
      tryThis: [
        'กด + ดูตัวเลขเพิ่ม แล้วเปิดไฟล์เทียบกับแลป "หลัง refactor"',
      ],
      files: ['lib/chapters/ch10/screens/setstate_counter_app.dart'],
      entry: (context) => const SetStateCounterApp(),
    ),
    Lab(
      id: 'ch10-after',
      title: 'หลัง refactor: ตัวนับด้วย Provider',
      goal:
          'เข้าใจ 4 ขั้น: สร้าง ChangeNotifier → ChangeNotifierProvider → context.watch (แสดง) → context.read (สั่งงาน) '
          'และเห็นว่า state เดียวถูกแชร์หลายจุด',
      tryThis: [
        'กด + แล้วดูว่าตัวเลขสองจุดบนจอเปลี่ยนพร้อมกัน (MyHomePage + CounterDisplay)',
        'ดู Debug Console: "CounterDisplay rebuild" ทุกครั้งที่กด',
        'ในโค้ด: ลองคิดว่าถ้าลบ notifyListeners() จะเกิดอะไร / ถ้าใช้ read แทน watch ใน build จะเกิดอะไร',
      ],
      files: [
        'lib/chapters/ch10/screens/provider_counter_app.dart',
        'lib/chapters/ch10/providers/counter_provider.dart',
      ],
      entry: (context) => const Ch10LabApp(),
    ),
  ],
);
