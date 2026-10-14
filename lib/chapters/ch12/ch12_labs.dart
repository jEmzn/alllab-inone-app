import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'screens/api_apps.dart';

/// บทที่ 12 — Asynchronous และ Networking
final LabChapter chapter12 = LabChapter(
  number: 12,
  title: 'Asynchronous และ Networking',
  subtitle: 'FutureBuilder, http + JSON, timeout/error/retry, compute, เชื่อมกับ Provider',
  icon: Icons.cloud_sync,
  labs: [
    Lab(
      id: 'ch12-future-demo',
      title: '12.4 FutureBuilder กับ Future.delayed',
      goal:
          'เข้าใจ 3 สถานะของ Future (รอ/สำเร็จ/ผิดพลาด) กับ FutureBuilder และเหตุผลที่ต้องสร้าง Future '
          'ใน initState ไม่ใช่ใน build',
      tryThis: [
        'รอ 3 วินาที: วงล้อ → ข้อความสำเร็จ',
        'เปิดสวิตช์ "จำลองข้อผิดพลาด" แล้วกด "รันใหม่" → ข้อความ error สีแดง',
        'ปิดสวิตช์ แล้วกด "รันใหม่" ตอนมีข้อมูลเก่า → สังเกตวงล้อที่ทับทั้งหน้า (ข้อเสียของลำดับ waiting ก่อน)',
      ],
      files: ['lib/chapters/ch12/screens/future_demo_screen.dart'],
      entry: (context) => const Ch12FutureDemoApp(),
    ),
    Lab(
      id: 'ch12-todo-list',
      title: '12.5–12.7 Todo จาก API (http + JSON + error + compute)',
      goal:
          'ดึงข้อมูลจริงด้วย http, แปลง JSON เป็น Model, แปลง error ทุกชนิดเป็น ApiException '
          'ที่ชั้นบริการ แล้วแสดงด้วย FutureBuilder + ปุ่มลองใหม่ + ลากรีเฟรช',
      tryThis: [
        'เลือก "เครือข่ายจริง" (ต้องมีอินเทอร์เน็ต) แล้วดูรายการ 200 รายการ · ไม่มีเน็ตใช้ "จำลอง: สำเร็จ"',
        'เลือกโหมดจำลองแต่ละแบบ แล้วลากลงเพื่อรีเฟรช: ไม่มีสัญญาณ / 500 มีปุ่มลองใหม่ · 404 และ HTML ไม่มีปุ่ม',
        'เลือก "ช้าเกิน" รอ 10 วินาทีเพื่อเห็น timeout',
        'ในไฟล์ api_service.dart อ่านลำดับ on TimeoutException → on FormatException → on ApiException → catch',
      ],
      files: [
        'lib/chapters/ch12/services/api_service.dart',
        'lib/chapters/ch12/screens/todo_list_screen.dart',
        'lib/chapters/ch12/models/todo.dart',
        'lib/chapters/ch12/screens/api_apps.dart',
      ],
      entry: (context) => const Ch12TodoListApp(),
    ),
    Lab(
      id: 'ch12-todo-provider',
      title: '12.8 เอาข้อมูลเครือข่ายเข้า Provider',
      goal:
          'เก็บสถานะ isLoading / errorMessage / ข้อมูล ไว้ใน ChangeNotifier และเรียก loadTodos() '
          'ผ่าน addPostFrameCallback โดยไม่ชน error "called during build"',
      tryThis: [
        'เปิดหน้า: วงล้อ → รายการ · กดปุ่ม refresh มุมขวาล่างเพื่อโหลดซ้ำ',
        'โหลดสำเร็จก่อน แล้วเปลี่ยนเป็นโหมดจำลอง error แล้วกด refresh → รายการเดิมยังอยู่ + แบนเนอร์ error',
        'เปลี่ยนโหมดเป็น error ก่อนเปิดหน้าครั้งแรก → เห็นหน้า error เต็มจอพร้อมปุ่มลองใหม่',
      ],
      files: [
        'lib/chapters/ch12/screens/todo_provider_screen.dart',
        'lib/chapters/ch12/providers/todo_provider.dart',
      ],
      entry: (context) => const Ch12TodoProviderApp(),
    ),
  ],
);
