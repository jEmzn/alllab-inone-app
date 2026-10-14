import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'screens/stateful_app.dart';

/// บทที่ 7 — ปฏิบัติการ: การจัดการ State ด้วย StatefulWidget
final LabChapter chapter07 = LabChapter(
  number: 7,
  title: 'State: StatefulWidget & setState',
  subtitle: 'ปฏิบัติการ stateful_app: ตัวนับ, ColorChanger, initState/dispose, ยก state ขึ้น',
  icon: Icons.touch_app,
  labs: [
    Lab(
      id: 'ch07-stateful-app',
      title: 'stateful_app (แบบฝึกหัด 1–6)',
      goal:
          'เข้าใจว่าข้อมูลที่เปลี่ยนได้อยู่ใน State, ต้องเรียก setState เพื่อให้ build ใหม่, '
          'และ initState/dispose ใช้ทำอะไร',
      tryThis: [
        'กดปุ่ม + มุมขวาล่าง แล้วดูตัวเลข (setState) · สังเกตว่าสี่เหลี่ยมไม่เปลี่ยนตาม',
        'แตะสี่เหลี่ยม "แตะฉัน!" เพื่อสุ่มสี',
        'ปิด/เปิดสวิตช์ "แสดง ColorChanger" แล้วดู Debug Console: dispose / initState (สีเริ่มต้นสุ่มใหม่)',
        'สลับ Switch ของ ChildWidget แล้วดูข้อความของ Parent และหลอดไฟเปลี่ยนพร้อมกัน',
        'ไปที่แท็บไฟล์ ลองลบ setState ในใจแล้วทายว่าจะเกิดอะไร',
      ],
      files: [
        'lib/chapters/ch07/screens/stateful_app.dart',
        'lib/chapters/ch07/screens/color_changer.dart',
        'lib/chapters/ch07/screens/lifting_state_section.dart',
      ],
      entry: (context) => const Ch07LabApp(),
    ),
  ],
);
