import 'package:flutter/foundation.dart';

import '../models/item.dart';

// ============================================================================
// ItemProvider (provider_shop) — เก็บรายการสินค้า
// ============================================================================
class ItemProvider extends ChangeNotifier {
  final List<Item> _items = [
    Item(id: 'i1', name: 'ปากกาสีน้ำเงิน', description: 'หมึกเจล เขียนลื่น', price: 25.0),
    Item(id: 'i2', name: 'สมุดบันทึกปกแข็ง', description: 'ขนาด A5, 120 แกรม', price: 89.0),
    Item(id: 'i3', name: 'คลิปหนีบกระดาษ', description: 'กล่องละ 50 ชิ้น, สีเงิน', price: 30.0),
  ];

  // [คืออะไร] คืน "สำเนา" ของลิสต์ด้วย spread operator [..._items]
  // [ทำไม]   กันภายนอกแก้ลิสต์จริงโดยไม่ผ่าน provider (เทียบกับแลปที่ 1 ที่คืนลิสต์ตรง ๆ)
  // [ข้อดี]   ปลอดภัยกว่า · [ข้อเสีย] สร้างลิสต์ใหม่ทุกครั้งที่เรียก getter (ราคาถูกถ้ารายการไม่ใหญ่)
  // [ข้อสอบ] เพราะคืนลิสต์ใหม่ทุกครั้ง ห้ามใช้ `p.items` เป็นค่าที่ select (== ไม่เท่าเสมอ)
  List<Item> get items => [..._items];

  // [คืออะไร] หา Item ตาม id · firstWhere จะ throw ถ้าไม่พบ
  // [ทำไม]   ส่ง "id" (String) ผ่าน route แทนส่งทั้งอ็อบเจกต์ → หน้าแก้ไขดึงของล่าสุดเอง
  Item findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  void updateItem(String id, Item newItemData) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items[itemIndex] = newItemData; // แทนที่ทั้งอ็อบเจกต์
      notifyListeners();
    }
  }
}
