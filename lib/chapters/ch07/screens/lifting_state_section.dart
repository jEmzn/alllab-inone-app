import 'package:flutter/material.dart';

// ============================================================================
// แบบฝึกหัด 6 (ทางเลือก): Lifting State Up — ยก state ขึ้นไปไว้ที่แม่
//
// ปัญหา: ลูก (ChildWidget) ต้องการเปลี่ยนค่าที่ "แม่" เก็บ แต่ลูกเรียก
//        setState ของแม่ตรง ๆ ไม่ได้
// วิธีแก้: ข้อมูลไหล "ลง" (isActive) · เหตุการณ์ไหล "ขึ้น" (callback)
//   1. แม่เก็บ state และมีเมธอดแก้ state ด้วย setState
//   2. แม่ส่ง "ค่า" + "ฟังก์ชัน callback" ลงไปทาง constructor ของลูก
//   3. ผู้ใช้สลับ Switch ในลูก → ลูกเรียก callback → แม่ setState → แม่ build ใหม่
//   4. แม่ส่งค่าใหม่ลงไปให้ลูกและพี่น้อง
//
// [ข้อดี]   state มีที่เดียว (single source of truth) พี่น้องซิงก์กันเอง
// [ข้อเสีย] ถ้า tree ลึก ต้องส่งค่า/callback ผ่านหลายชั้น → ยุ่ง
//           นี่คือเหตุผลที่บทที่ 10 ใช้ Provider สำหรับ app state
// ============================================================================

// ---------------------------------------------------------------------------
// ParentWidget — เจ้าของ state
// ---------------------------------------------------------------------------
// [จำเป็น?] ต้องเป็น Stateful เพราะเป็นผู้ถือ _isActive
class LiftingStateSection extends StatefulWidget {
  const LiftingStateSection({super.key});

  @override
  State<LiftingStateSection> createState() => _LiftingStateSectionState();
}

class _LiftingStateSectionState extends State<LiftingStateSection> {
  bool _isActive = false; // state ถูกเก็บโดย parent

  // [คืออะไร] callback ที่จะส่งให้ลูก
  // [ทำไม]   เมธอดนี้อยู่ใน parent จึงเรียก setState ของ parent ได้
  //          ลูกเพียงแค่ "แจ้ง" ว่ามีค่าใหม่ ไม่ได้แก้ state เอง
  void _handleActiveChange(bool newValue) {
    setState(() {
      _isActive = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('สถานะ Parent คือ: ${_isActive ? "Active" : "Inactive"}'),
        // [คืออะไร] ส่ง "ค่า" ลง และ "ฟังก์ชัน" ลง
        ChildWidget(
          isActive: _isActive,
          onActiveChanged: _handleActiveChange,
        ),
        // [ข้อดี] พี่น้องของ ChildWidget อ่านค่าเดียวกันได้โดยไม่รู้จัก Switch เลย
        //         — นี่คือเหตุผลที่ต้องยก state ขึ้นไปไว้ที่ ancestor ร่วม
        Row(
          children: [
            const Text('หลอดไฟ (พี่น้อง): '),
            Icon(
              _isActive ? Icons.lightbulb : Icons.lightbulb_outline,
              color: _isActive ? Colors.amber : null,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ChildWidget — ไม่มี state ของตัวเอง
// ---------------------------------------------------------------------------
// [คืออะไร] StatelessWidget ที่รับทั้งค่าและ callback
// [ทำไม]   ไม่เก็บ state เอง → ใช้ซ้ำได้ง่าย, ทดสอบง่าย (ใส่ค่าอะไรก็แสดงตามนั้น)
// [ข้อดี]   ลูกไม่ต้องรู้ว่าแม่เอาค่าไปทำอะไร
class ChildWidget extends StatelessWidget {
  final bool isActive;

  // [คืออะไร] ValueChanged<bool> = typedef ของ void Function(bool)
  // [ทำไม]   ใช้ชื่อมาตรฐานของ Flutter ให้ตรงกับ Switch.onChanged
  final ValueChanged<bool> onActiveChanged;

  const ChildWidget({
    super.key,
    required this.isActive,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('ChildWidget: '),
        // ส่งต่อ callback ที่ได้รับ ให้ Switch เรียกเมื่อผู้ใช้สลับ
        Switch(value: isActive, onChanged: onActiveChanged),
      ],
    );
  }
}
