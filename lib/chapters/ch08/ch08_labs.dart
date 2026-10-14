import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'screens/login_form_app.dart';

/// บทที่ 8 — ปฏิบัติการ: การสร้างและตรวจสอบความถูกต้องของฟอร์ม
final LabChapter chapter08 = LabChapter(
  number: 8,
  title: 'Input ของผู้ใช้และฟอร์ม',
  subtitle: 'ปฏิบัติการ: ฟอร์มล็อกอิน (Form, TextFormField, validator, onSaved)',
  icon: Icons.edit_note,
  labs: [
    Lab(
      id: 'ch08-login-form',
      title: 'ฟอร์มล็อกอิน (แบบฝึกหัด 1–5)',
      goal:
          'เข้าใจบทบาทของ Form + GlobalKey<FormState>, TextFormField, validator, onSaved, '
          'TextEditingController และการปรับฟอร์มให้ใช้บนมือถือจริงได้',
      tryThis: [
        'กด "ล็อกอิน" โดยไม่กรอกอะไร → error ใต้ทั้งสองช่อง',
        'ใส่อีเมล "test" → ยังไม่ผ่าน · ใส่รหัสผ่าน "123" → ยังไม่ผ่าน',
        'หลังกดส่งแล้ว ลองแก้ช่องที่ผิดให้ถูก → error หายทันที (autovalidateMode)',
        'ใส่อีเมลที่มีช่องว่างหัวท้าย " you@example.com " → ผ่าน และ SnackBar แสดงแบบไม่มีช่องว่าง',
        'กรอกถูกแล้วกดล็อกอิน → SnackBar + ช่องรหัสผ่านถูกล้าง · ลองกด Enter ที่ช่องรหัสผ่าน',
        'แตะรูปตาเพื่อสลับซ่อน/แสดงรหัสผ่าน',
      ],
      files: [
        'lib/chapters/ch08/screens/login_form_screen.dart',
        'lib/chapters/ch08/screens/login_form_app.dart',
      ],
      entry: (context) => const Ch08LabApp(),
    ),
  ],
);
