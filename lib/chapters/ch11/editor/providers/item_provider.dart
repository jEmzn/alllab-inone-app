import 'package:flutter/foundation.dart';

import '../models/item.dart';

// ============================================================================
// ItemProvider — "แหล่งข้อมูลจริงเพียงแหล่งเดียว" (Single Source of Truth)
//
// [คืออะไร] ChangeNotifier ที่ถือรายการสินค้าทั้งหมดไว้ในหน่วยความจำ
// [ทำไม]   ทั้งหน้ารายการและหน้าแก้ไขต้องเห็นข้อมูลชุดเดียวกัน → เก็บไว้ที่เดียว
//          แล้วให้สองหน้าไปอ่าน/แก้ผ่านมัน ไม่ใช่ส่งสำเนาไปมา
// [ข้อดี]   แก้ที่เดียว ทุกหน้าที่ฟังอยู่อัปเดตเอง
// [ข้อเสีย] ข้อมูลอยู่ใน RAM เท่านั้น ปิดแอปแล้วหาย (บท 13 แก้ด้วย SQLite)
// ============================================================================
class ItemProvider extends ChangeNotifier {
  // ข้อมูลตัวอย่างเริ่มต้น
  final List<Item> _items = [
    Item(id: '1', name: 'MacBook Pro', description: 'Apple M3 Pro Chip'),
    Item(id: '2', name: 'Dell XPS 15', description: 'Intel Core i9, 32GB RAM'),
    Item(id: '3', name: 'Logitech MX Master 3S', description: 'Wireless Mouse'),
  ];

  // [คืออะไร] getter ให้ UI อ่านรายการ
  // [ข้อเสีย] คืน "ลิสต์ตัวจริง" ออกไปตรง ๆ → ผู้เรียก .add()/.remove() ได้โดยไม่ผ่าน provider
  //          (ไม่ notifyListeners) ทางที่ปลอดภัยกว่าคือคืนสำเนา `[..._items]`
  //          หรือ List.unmodifiable — แลป provider_shop ทำแบบนั้น
  List<Item> get items => _items;

  // [คืออะไร] อัปเดตสินค้าตาม id
  void updateItem(String id, String newName, String newDescription) {
    // [คืออะไร] indexWhere คืนตำแหน่งแรกที่เงื่อนไขเป็นจริง หรือ -1 ถ้าไม่พบ
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items[itemIndex].name = newName;
      _items[itemIndex].description = newDescription;

      // [จำเป็น?] จำเป็น — แจ้ง "ผู้ฟัง" (Consumer ในหน้ารายการ) ว่ามีการเปลี่ยนแปลง
      // [ข้อสอบ] อยู่ใน if เพราะถ้าไม่พบ id ก็ไม่มีอะไรเปลี่ยน ไม่ต้องปลุก UI เปล่า ๆ
      notifyListeners();
    }
  }
}
