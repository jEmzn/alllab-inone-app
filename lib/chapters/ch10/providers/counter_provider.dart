import 'package:flutter/foundation.dart';

// ============================================================================
// CounterProvider — "State Model" (ส่วนที่ 2 ของแลป)
//
// [คืออะไร] คลาสที่เก็บ state + ตรรกะแก้ state ไว้ "นอก" UI
//          ทำได้โดย extends ChangeNotifier (มาจาก flutter/foundation.dart
//          ไม่ใช่ของแพ็กเกจ provider — provider แค่เอามาใช้ประโยชน์)
// [ทำไม]   แยก state ออกจาก UI (Separation of Concerns):
//          UI มีหน้าที่แสดงผล + ส่งการกระทำของผู้ใช้ · Model มีหน้าที่ถือข้อมูลและกฎ
// [ข้อดี]   ทดสอบ Model ได้โดยไม่ต้องสร้างหน้าจอ · หลายหน้าจอใช้ state เดียวกันได้
// [ข้อเสีย] มีไฟล์/คลาสเพิ่ม ถ้า state เล็กมากและใช้หน้าเดียว setState ง่ายกว่า
// ============================================================================
class CounterProvider extends ChangeNotifier {
  // [คืออะไร] ตัวแปร state — ประกาศ private (_)
  // [ทำไม]   กันโค้ดภายนอกแก้ค่าตรง ๆ โดยไม่ผ่านเมธอด (ซึ่งจะลืม notifyListeners)
  int _count = 0;

  // [คืออะไร] getter สาธารณะ "อ่านอย่างเดียว"
  // [ข้อดี]   UI อ่านค่าได้ (provider.count) แต่แก้ไม่ได้
  int get count => _count;

  // [คืออะไร] เมธอดที่เปลี่ยน state — แทน _incrementCounter() เดิมที่เคยอยู่ใน State
  void increment() {
    _count++;

    // [คืออะไร] ประกาศให้ "ทุกคนที่ฟังอยู่" ทราบว่า state เปลี่ยน
    // [ทำไม]   นี่คือคู่ของ setState ในโลก Provider: setState สั่ง rebuild ตัวเอง
    //          ส่วน notifyListeners สั่ง rebuild "ทุกวิดเจ็ตที่ watch/Consumer provider นี้"
    // [จำเป็น?] จำเป็นที่สุด! ลืมบรรทัดนี้ → ค่าเปลี่ยนแต่หน้าจอไม่ขยับ (บั๊กยอดนิยม)
    // [ข้อสอบ] เรียกหลังแก้ค่าเสมอ
    notifyListeners();
  }
}
