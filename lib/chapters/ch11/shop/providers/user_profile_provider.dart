import 'package:flutter/foundation.dart';

// ============================================================================
// UserProfileProvider — provider ตัวที่ 2 (ข้อมูลผู้ใช้)
//
// [ทำไม]   แยกจาก ItemProvider ตาม "ขอบเขตความรับผิดชอบ" (หัวข้อ 11.8):
//          ชื่อผู้ใช้กับรายการสินค้าไม่ได้เปลี่ยนไปพร้อมกัน และเหตุผลที่ต้องแก้ต่างกัน
//          การเปลี่ยนชื่อผู้ใช้จึงไม่ควรปลุกวิดเจ็ตที่สนใจแต่สินค้า
// [ข้อดี]   notifyListeners ของแต่ละตัวปลุกเฉพาะผู้ที่เกี่ยวข้อง
// [ข้อเสีย] ถ้าหั่นมากเกินไปแล้วต้องแก้หลายตัวพร้อมกันเสมอ = หั่นเกิน
// ============================================================================
class UserProfileProvider extends ChangeNotifier {
  String _username = 'Student101';
  String get username => _username;

  void changeUsername(String newName) {
    _username = newName;
    notifyListeners();
  }
}
