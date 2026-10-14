import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/api_service.dart';

// ============================================================================
// TodoProvider — เอาข้อมูลจากเครือข่ายเข้าสู่ Provider (หัวข้อ 12.8)
//
// เลือก FutureBuilder หรือ Provider?
//   FutureBuilder: ข้อมูลใช้หน้าเดียว ดึงครั้งเดียวตอนเปิดหน้า ไม่ต้องสั่งโหลดซ้ำจากที่อื่น
//   Provider     : ข้อมูลใช้ร่วมหลายหน้า / สั่งโหลดซ้ำได้ / ต้องอยู่รอดตอนสลับหน้า
//   (เกณฑ์ = "วงจรชีวิตของข้อมูล" ไม่ใช่ความยากง่ายของเครื่องมือ)
//
// งาน async ทุกชนิดมี 3 สถานะ: กำลังโหลด · สำเร็จ · ผิดพลาด  ← ใช้ซ้ำในบท 13 กับ SQLite
// ============================================================================
class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // [คืออะไร] List.unmodifiable คืน "มุมมองที่แก้ไม่ได้"
  // [ทำไม]   บังคับให้การแก้ข้อมูลทุกครั้งผ่านเมธอดของคลาสนี้ (ซึ่งเรียก notifyListeners)
  //          ถ้าคืน _todos ตรง ๆ หน้าจออาจแก้ลิสต์โดยที่ UI ไม่ถูกแจ้งให้วาดใหม่
  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // แจ้ง UI ให้แสดงสถานะกำลังโหลด

    try {
      _todos = await fetchTodos();
    } on ApiException catch (e) {
      // ชั้นบริการแปลงข้อผิดพลาดมาเป็นข้อความภาษาคนให้แล้ว
      _errorMessage = e.message;
      // [ข้อสอบ] ไม่ล้าง _todos → ผู้ใช้ยังเห็นข้อมูลรอบก่อนแม้โหลดซ้ำล้มเหลว
    } catch (e) {
      _errorMessage = 'ไม่สามารถโหลดข้อมูลได้';
    } finally {
      // [ข้อสอบ] finally ทำงานทั้งสำเร็จ/ล้มเหลว → ปิด isLoading แล้วแจ้ง UI รอบสอง
      //          (เรียก notifyListeners "สองครั้ง" ต่อการโหลดหนึ่งรอบ: ตอนเริ่ม + ตอนจบ)
      _isLoading = false;
      notifyListeners();
    }
  }
}
