import 'package:flutter/material.dart';

// ============================================================================
// แลป 12.4: FutureBuilder กับงานจำลอง (Future.delayed)
//
// [ทำไม]   จำลองการรอ 3 วินาทีก่อน แทนที่จะต่อเน็ตจริงทันที: เราควบคุมได้ว่าจะ "สำเร็จ"
//          หรือ "ล้มเหลว" และรอกี่วินาที → ทดสอบ UI ครบทั้ง 3 สถานะก่อน
//          พอสลับไปเน็ตจริง (แลปถัดไป) จะเหลือตัวแปรที่อาจผิดแค่ด้านเดียว
// ============================================================================
class FutureDemoScreen extends StatefulWidget {
  const FutureDemoScreen({super.key});

  @override
  State<FutureDemoScreen> createState() => _FutureDemoScreenState();
}

class _FutureDemoScreenState extends State<FutureDemoScreen> {
  // [คืออะไร] ตัวแปรเก็บ Future ไว้ใน State
  // [ข้อสอบ] ห้ามเรียก simulateSlowOperation() ใน build() ตรง ๆ!
  //          build ถูกเรียกซ้ำบ่อย (แอนิเมชัน/คีย์บอร์ด/แม่ rebuild) → ได้ Future ตัวใหม่ทุกครั้ง
  //          → FutureBuilder เริ่มรอใหม่ไม่รู้จบ (วงล้อหมุนไม่หยุด และยิงคำขอรัว ๆ)
  //          ต้องสร้างใน initState แล้วเก็บไว้ในตัวแปร
  late Future<String> _calculation;

  // [เฉพาะแลปนี้] ตำราให้ "ยกเลิกคอมเมนต์ throw" เพื่อทดสอบ error — ที่นี่ใช้สวิตช์แทน
  bool _shouldFail = false;

  Future<String> simulateSlowOperation() {
    // [คืออะไร] Future.delayed(duration, computation) — รอแล้วค่อยรัน computation
    return Future.delayed(const Duration(seconds: 3), () {
      if (_shouldFail) {
        // throw ใน Future → Future จบด้วย "ข้อผิดพลาด" (snapshot.hasError = true)
        throw Exception('เกิดข้อผิดพลาดโดยตั้งใจ');
      }
      return 'ข้อมูลจากการทำงานที่ใช้เวลานาน';
    });
  }

  @override
  void initState() {
    super.initState();
    // เรียกครั้งเดียวตอนสร้างหน้าจอ แล้วเก็บ Future ไว้
    _calculation = simulateSlowOperation();
  }

  // [คืออะไร] "ลองใหม่" = สร้าง Future ตัวใหม่ + setState ให้ FutureBuilder เปลี่ยนมาฟังตัวใหม่
  // [ข้อสอบ] Future หนึ่งตัวให้ผลได้ "ครั้งเดียว" ตลอดอายุ จึงสั่งตัวเดิมรันซ้ำไม่ได้
  //          (กรณีนี้ไม่มี await คั่น จึงไม่ต้องเช็ก mounted)
  void _reload() {
    setState(() {
      _calculation = simulateSlowOperation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FutureBuilder Demo')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('จำลองให้เกิดข้อผิดพลาด'),
            value: _shouldFail,
            onChanged: (v) => setState(() => _shouldFail = v),
          ),
          FilledButton(onPressed: _reload, child: const Text('รันใหม่')),
          Expanded(
            child: Center(
              // [คืออะไร] FutureBuilder = วิดเจ็ตที่ "ฟัง" Future แล้วสร้าง UI ตามสถานะล่าสุด
              //          (ทำหน้าที่ที่เราต้องเขียนเองด้วย setState + isLoading + error + mounted)
              // [ข้อสอบ] พารามิเตอร์หลัก 2 ตัว: future (ตัวที่ฟัง) และ builder (context, snapshot)
              child: FutureBuilder<String>(
                future: _calculation,
                builder: (context, snapshot) {
                  // snapshot = ภาพถ่ายสถานะล่าสุดของ Future ณ ตอนที่ builder ถูกเรียก
                  //   connectionState : none / waiting / active / done
                  //   hasData / data  · hasError / error

                  // 1. กำลังรอ
                  // [ข้อเสีย] ตรวจ waiting เป็นอย่างแรก ใช้ได้เมื่อโหลดครั้งเดียว
                  //          แต่ถ้า "รันใหม่" ตอนมีข้อมูลเก่า snapshot จะเป็น waiting พร้อม
                  //          hasData == true (ข้อมูลรอบก่อนยังค้างอยู่) → วงล้อหมุนทับทั้งหน้า
                  //          เกิดอาการ "กระพริบ" ทุกครั้งที่รีเฟรช — ลองกด "รันใหม่" ดู
                  //          วิธีแก้ (12.6): ตรวจ error ก่อน แล้วค่อยเช็ก !hasData → ดู todo_list_screen
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('กำลังโหลดข้อมูล...'),
                      ],
                    );
                  }
                  // 2. ผิดพลาด
                  else if (snapshot.hasError) {
                    return Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  // 3. สำเร็จ
                  else if (snapshot.hasData) {
                    return Text(
                      'สำเร็จ! ได้รับข้อมูล: ${snapshot.data}',
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    );
                  }
                  // 4. อื่น ๆ (เช่น connectionState.none) — builder ต้อง "คืนวิดเจ็ตเสมอ"
                  else {
                    return const Text('ไม่มีข้อมูล');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
