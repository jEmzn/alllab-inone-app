import 'package:flutter/foundation.dart';

import '../../../ch12/models/todo.dart';
import '../repositories/todo_repository.dart';

// ============================================================================
// TodoProvider (offline-first) — คำตอบข้อ 3 ของคำถามท้ายบท 12:
// "สามสถานะ (โหลด/สำเร็จ/ผิดพลาด) ยังพอไหม?" → ไม่พอเมื่อมีข้อมูลในเครื่อง
// ต้องเก็บเป็น "หลายค่าที่ประกอบกันได้" แทนค่าเดียว:
//    รายการข้อมูล · กำลังรีเฟรชอยู่ไหม · ข้อความผิดพลาดล่าสุด · เวลาซิงก์สำเร็จครั้งล่าสุด
// ทำให้หน้าจอแยกได้ 4 สถานการณ์ (ดู todo_list_screen.dart)
// ============================================================================
class TodoProvider extends ChangeNotifier {
  // [คืออะไร] รับ repository ผ่าน constructor — provider ไม่รู้ว่าข้อมูลมาจากเน็ตหรือไฟล์
  TodoProvider(this._repository);
  final TodoRepository _repository;

  List<Todo> _todos = [];
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSynced;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSynced => _lastSynced;

  Future<void> load() async {
    // 1. แสดงชุดในเครื่องก่อน (เร็วมาก ไม่รอเครือข่าย)
    _todos = await _repository.readCached();
    _isRefreshing = true;
    notifyListeners(); // ผู้ฟังวาดรายการเดิม + แถบรีเฟรชได้ทันที

    // 2. ขอชุดใหม่ ถ้าไม่สำเร็จ ชุดเดิมยังอยู่บนจอ
    try {
      _todos = await _repository.refresh();
      _lastSynced = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      // [ข้อดี] ตำราใช้ข้อความกลาง 'เกิดข้อผิดพลาด' ทุกกรณี — ที่นี่ปรับให้ใช้ข้อความของ
      //        ApiException (ซึ่งเป็นภาษาคนอยู่แล้ว: ไม่มีสัญญาณ/ช้าเกิน/เซิร์ฟเวอร์ล่ม) ผู้ใช้รู้ว่าต้องทำอะไรต่อ
      _errorMessage = e is Exception ? e.toString() : 'เกิดข้อผิดพลาด';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
