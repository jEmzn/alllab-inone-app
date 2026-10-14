import 'dart:math'; // จำเป็นสำหรับ Random

import 'package:flutter/material.dart';

// ============================================================================
// แบบฝึกหัด 3-5: ColorChanger
//   3. วิดเจ็ตที่แตะแล้วเปลี่ยนสี (setState)
//   4. สีเริ่มต้นสุ่มใน initState
//   5. สร้าง/คืน TextEditingController ใน initState/dispose
//
// ทำไมแยกเป็นไฟล์/คลาสของตัวเอง?
//   [ข้อดี] state ของสี "ใกล้" กับ UI ที่ใช้มัน และ setState จะ rebuild
//           เฉพาะ subtree นี้ ไม่ลามไปทั้งหน้า (ประสิทธิภาพดีกว่าเก็บทุกอย่างไว้ที่ MyHomePage)
//   [ข้อเสีย] ถ้าวิดเจ็ตอื่นต้องรู้สีนี้ด้วย ต้อง "ยก state ขึ้น" หรือใช้ Provider (บท 10)
// ============================================================================
class ColorChanger extends StatefulWidget {
  const ColorChanger({super.key});

  @override
  State<ColorChanger> createState() => _ColorChangerState();
}

class _ColorChangerState extends State<ColorChanger> {
  // [คืออะไร] ตัวแปร state ของสีปัจจุบัน
  // [ทำไม]   ใช้ `late` เพราะจะกำหนดค่าใน initState (แบบฝึกหัด 4) ไม่ใช่ตอนประกาศ
  //          — `late` สัญญากับคอมไพเลอร์ว่า "ไม่เป็น null แน่ ก่อนถูกใช้ครั้งแรก"
  // [ข้อเสีย] ถ้าลืมกำหนดค่าก่อนใช้ จะ error ตอนรัน (LateInitializationError)
  //          ไม่ใช่ตอนคอมไพล์
  // [ทางเลือก] ตอนแรก (แบบฝึกหัด 3) ใช้ `Color _currentColor = Colors.blue;` ได้เลย
  late Color _currentColor;

  // [คืออะไร] รายการสีที่สุ่มเลือก
  // [ทำไม]   final = ตัวลิสต์ไม่ถูกกำหนดใหม่ (แต่ยังเพิ่ม/ลดสมาชิกได้) · ไม่ใช่ state
  //          เพราะไม่เคยเปลี่ยนและไม่กระทบ UI โดยตรง จึงไม่ต้องผ่าน setState
  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  // [คืออะไร] ตัวสุ่มเลข — สร้างครั้งเดียวเก็บเป็น field
  // [ทำไม]   ไม่ควรสร้าง Random() ใหม่ทุกครั้งที่กด (สิ้นเปลือง และบางกรณีได้เลขซ้ำ)
  final Random _random = Random();

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 5: controller ที่ต้องมี dispose
  // -------------------------------------------------------------------------
  // [คืออะไร] TextEditingController — ตัวควบคุมช่องข้อความ (บทที่ 8)
  //          ที่นี่ "ยังไม่ได้ผูกกับ TextField" ใช้ฝึกรูปแบบ initState/dispose เฉยๆ
  // [ทำไม]   `late final` = กำหนดค่าครั้งเดียว (ใน initState) แล้วเปลี่ยนไม่ได้
  // [จำเป็น?] ในแลปนี้ "ไม่จำเป็น" (ไม่ได้ใช้จริง) · แต่ในงานจริง controller ทุกตัว
  //          ต้องถูก dispose ไม่งั้นรั่ว memory
  late final TextEditingController _controller;

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 4: initState
  // -------------------------------------------------------------------------
  // [คืออะไร] ถูกเรียก "ครั้งเดียว" ตอน State ถูกสร้างและใส่เข้า tree ครั้งแรก
  // [ทำไม]   เป็นที่ตั้งค่าเริ่มต้นที่ต้องทำครั้งเดียว: ค่าเริ่มต้นของ state,
  //          สร้าง controller, subscribe stream
  // [ข้อสอบ] เรียก super.initState() เป็นบรรทัดแรกเสมอ
  // [ข้อเสีย] อย่าเริ่มงานที่ใช้ context ซับซ้อนที่นี่ (ยังอ่าน InheritedWidget
  //          แบบ listen ไม่ได้ → ใช้ didChangeDependencies แทน)
  @override
  void initState() {
    super.initState(); // ต้องเรียกก่อนเสมอ
    _currentColor = _availableColors[_random.nextInt(_availableColors.length)];
    _controller = TextEditingController();
    // [คืออะไร] debugPrint = print ที่ปลอดภัยกว่า (ไม่ถูกตัดเมื่อข้อความยาว) ดูใน Debug Console
    debugPrint('initState: สีเริ่มต้น $_currentColor, controller ถูกสร้างแล้ว');
  }

  // [คืออะไร] ถูกเรียกเมื่อ State ถูกลบออกจาก tree "ถาวร"
  // [ทำไม]   ที่สำหรับคืนทรัพยากร: controller.dispose(), ยกเลิก Timer/Stream
  // [จำเป็น?] จำเป็นกับของที่เราสร้างเอง — ถ้าไม่ทำ = memory leak
  // [ข้อสอบ] กฎคู่: initState → super ก่อน / dispose → super.dispose() "ท้ายสุด"
  @override
  void dispose() {
    debugPrint('dispose: กำลัง dispose controller');
    _controller.dispose(); // คืนทรัพยากรก่อน
    super.dispose(); // แล้วเรียก super เป็นลำดับสุดท้าย
  }

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 3: เปลี่ยนสีด้วย setState
  // -------------------------------------------------------------------------
  void _changeColor() {
    setState(() {
      // สุ่ม index ในช่วง 0..length-1 แล้วหยิบสีจากลิสต์
      _currentColor = _availableColors[_random.nextInt(_availableColors.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] GestureDetector — ตัวตรวจจับท่าทาง (แตะ ลาก กดค้าง)
    // [ทำไม]   Container ไม่รับการแตะเอง จึงต้องห่อด้วย GestureDetector
    // [ทางเลือก] InkWell ให้เอฟเฟกต์ระลอกคลื่น (ต้องอยู่ใต้ Material) ·
    //          ElevatedButton ถ้าต้องการปุ่มจริง ๆ
    // [ข้อเสีย] GestureDetector ไม่มีเอฟเฟกต์ภาพเมื่อกด ผู้ใช้อาจไม่รู้ว่าแตะได้
    return Center(
      child: GestureDetector(
        onTap: _changeColor,
        child: Container(
          width: 150,
          height: 150,
          // ใช้ตัวแปร state ตรงนี้ → เมื่อ setState แล้ว build ใหม่ สีจะเปลี่ยน
          color: _currentColor,
          alignment: Alignment.center,
          child: const Text(
            'แตะฉัน!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
