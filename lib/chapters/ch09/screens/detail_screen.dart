import 'package:flutter/material.dart';

// ============================================================================
// DetailScreen — หน้าปลายทางของแบบฝึกหัด 1-3
//   แบบฝึกหัด 1: pop พื้นฐาน
//   แบบฝึกหัด 2: รับข้อมูลผ่าน constructor (message)
//   แบบฝึกหัด 3: pop พร้อมส่งผลลัพธ์กลับ
//
// [คืออะไร] StatelessWidget — แสดงข้อมูลที่รับมาอย่างเดียว ไม่มี state
// ============================================================================
class DetailScreen extends StatelessWidget {
  // [คืออะไร] ข้อมูลที่ส่งมา · final เพราะวิดเจ็ตเปลี่ยนค่าไม่ได้
  // [ทำไม]   มีค่าเริ่มต้น เพื่อให้แบบฝึกหัด 1 (ไม่ส่งอะไร) ใช้คลาสเดียวกันได้
  //          (ในตำราแบบฝึกหัด 2 เปลี่ยนเป็น required — ที่นี่ผ่อนปรนเพื่อรวมหลายแบบฝึกหัด)
  final String message;

  // [ทำไม]   ธงเลือกว่าปุ่ม "ย้อนกลับ" จะส่งผลลัพธ์ (แบบฝึกหัด 3) หรือไม่ (แบบฝึกหัด 1-2)
  final bool returnsResult;

  const DetailScreen({
    super.key,
    this.message = 'รายละเอียดอยู่ที่นี่',
    this.returnsResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [ข้อสอบ] AppBar ของหน้าที่ถูก push จะมีลูกศรย้อนกลับให้อัตโนมัติ
      //          (ตรงกับ Navigator.pop) — ปุ่มกลับของระบบ Android/ท่าปัด iOS ก็ pop เช่นกัน
      appBar: AppBar(title: const Text('หน้ารายละเอียด')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (returnsResult) {
                  // [คืออะไร] pop(context, ค่า) — เอาหน้านี้ออก + ส่งค่านั้นเป็นผลลัพธ์ของ push
                  // [ข้อสอบ] ชนิดของค่าต้องตรงกับที่ผู้เรียกคาดหวัง (ที่นี่เป็น String)
                  Navigator.pop(context, 'สำเร็จ! ข้อมูลจากรายละเอียด');
                } else {
                  // pop เฉย ๆ → ผลลัพธ์ฝั่งผู้เรียกเป็น null
                  // [ข้อควรระวัง] ถ้าหน้านี้เป็นหน้าแรกของ stack จะเหลือหน้าดำ
                  //   → ตรวจก่อนด้วย Navigator.canPop(context) หรือใช้ maybePop
                  Navigator.pop(context);
                }
              },
              child: const Text('ย้อนกลับ'),
            ),
          ],
        ),
      ),
    );
  }
}
