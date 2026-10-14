import 'package:flutter/material.dart';

import '../../core/lab.dart';
import 'editor/screens/editor_app.dart';
import 'rebuild/screens/rebuild_lab_app.dart';
import 'shop/screens/shop_app.dart';

/// บทที่ 11 — ปฏิบัติการ: Provider/Consumer/select/MultiProvider
final LabChapter chapter11 = LabChapter(
  number: 11,
  title: 'Provider ขั้นสูง',
  subtitle: 'Consumer, select, MultiProvider — แอปแก้ไขรายการ 2 หน้าจอ และแลปวัดการ rebuild',
  icon: Icons.account_tree,
  labs: [
    Lab(
      id: 'ch11-editor',
      title: 'ปฏิบัติการที่ 1: provider_editor_lab',
      goal:
          'แชร์ state ข้าม 2 หน้าจอด้วย provider ตัวเดียว: หน้ารายการ (Consumer) + หน้าแก้ไข (context.read) '
          'และเข้าใจว่าทำไมต้องใช้ didChangeDependencies พร้อม "ยาม" _isInit',
      tryThis: [
        'แตะ "Dell XPS 15" → แก้คำอธิบาย → บันทึก แล้วดูหน้ารายการอัปเดตเอง',
        'ดู Debug Console: "ItemListScreen.build()" ขึ้นครั้งเดียว ส่วน "Consumer.builder" ขึ้นทุกครั้งที่บันทึก',
        'ในไฟล์ edit_item_screen.dart: ลองคิดว่าถ้าลบ _isInit ออกจะเกิดอะไรเมื่อหมุนจอ',
      ],
      files: [
        'lib/chapters/ch11/editor/screens/item_list_screen.dart',
        'lib/chapters/ch11/editor/screens/edit_item_screen.dart',
        'lib/chapters/ch11/editor/providers/item_provider.dart',
        'lib/chapters/ch11/editor/models/item.dart',
        'lib/chapters/ch11/editor/screens/editor_app.dart',
      ],
      entry: (context) => const Ch11EditorLabApp(),
    ),
    Lab(
      id: 'ch11-shop',
      title: 'ปฏิบัติการที่ 2: provider_shop (MultiProvider + ฟอร์ม)',
      goal:
          'ใช้ MultiProvider กับ provider 2 ตัว, ฟอร์มแก้ไขที่มี validator/onSaved, '
          'และความท้าทาย: context.select / Selector ต่อแถว เพื่อตีกรอบ rebuild',
      tryThis: [
        'กดไอคอนคน (AppBar) เปลี่ยนชื่อผู้ใช้ → ดู console: มีแค่ _UsernameTitle build ไม่ใช่ทั้งหน้า',
        'แตะสินค้า → แก้ → บันทึก → console มี "_ItemTile build" เพียงแถวเดียว (ไม่ใช่ทุกแถว)',
        'ลองใส่ราคาว่าง / ตัวอักษร / 0 → ดูข้อความ validator แต่ละแบบ',
      ],
      files: [
        'lib/chapters/ch11/shop/screens/shop_app.dart',
        'lib/chapters/ch11/shop/screens/item_list_screen.dart',
        'lib/chapters/ch11/shop/screens/edit_item_screen.dart',
        'lib/chapters/ch11/shop/providers/item_provider.dart',
        'lib/chapters/ch11/shop/providers/user_profile_provider.dart',
        'lib/chapters/ch11/shop/models/item.dart',
      ],
      entry: (context) => const Ch11ShopLabApp(),
    ),
    Lab(
      id: 'ch11-rebuild',
      title: 'แลปวัด rebuild: watch / Consumer / child / select',
      goal:
          'เห็นด้วยตาว่าแต่ละวิธีรับฟังทำให้ส่วนไหน rebuild บ้าง (ตัวเลข build ×n สีส้ม) — '
          'หลักฐานของ "บันไดการรับฟัง" ในหัวข้อ 11.2–11.5',
      tryThis: [
        'เลือก "1 watch" แล้วกด "เปลี่ยนชื่อเล่น" → ทั้งสามส่วนนับเพิ่ม',
        'เลือก "2 Consumer" → เฉพาะชื่อเล่นเพิ่ม · แต่กด "เปลี่ยนสีรูป" แล้วรูปไม่เปลี่ยนสี (เพราะใช้ read)',
        'เลือก "3 Consumer+child" → ป้ายยืนยันไม่เคยเพิ่ม',
        'เลือก "4 select" → กด "เปลี่ยนสีรูป" ชื่อเล่นไม่เพิ่ม แต่กด "เปลี่ยนชื่อเล่น" เพิ่ม',
      ],
      files: [
        'lib/chapters/ch11/rebuild/screens/rebuild_lab_app.dart',
        'lib/chapters/ch11/rebuild/providers/user_provider.dart',
      ],
      entry: (context) => const Ch11RebuildLabApp(),
    ),
  ],
);
