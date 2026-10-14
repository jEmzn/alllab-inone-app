import 'package:flutter/material.dart';

import 'color_changer.dart';
import 'lifting_state_section.dart';

// ============================================================================
// แลปบทที่ 7: StatefulWidget + setState  (ไฟล์นี้ = main.dart + MyHomePage)
//
// ไฟล์ในแลปนี้:
//   stateful_app.dart          ← (ไฟล์นี้) แอปหลัก + แบบฝึกหัด 1-2 ตัวนับ
//   color_changer.dart         ← แบบฝึกหัด 3-5 (setState, initState, dispose)
//   lifting_state_section.dart ← แบบฝึกหัด 6 (ยก state ขึ้นด้วย callback)
//
// ภาพรวมที่ต้องเข้าใจ:
//   "วิดเจ็ตเปลี่ยนค่าไม่ได้ (immutable)" → ข้อมูลที่เปลี่ยนได้ไปอยู่ใน State object
//   → แก้ข้อมูลแล้วต้องบอก Flutter ด้วย setState() → Flutter เรียก build() ใหม่
// ============================================================================

// ---------------------------------------------------------------------------
// MyApp — รากของแอป (เทียบได้กับ MyApp ใน main.dart ของแลป)
// ---------------------------------------------------------------------------
// [คืออะไร] StatelessWidget ที่คืน MaterialApp ซึ่งเป็น "ตัวห่อ" ของทั้งแอป
//           (กำหนด theme, ระบบนำทาง/Navigator, ภาษา ฯลฯ)
// [ทำไม]   ตัวมันเองไม่มีข้อมูลที่เปลี่ยนตามเวลา จึงใช้ Stateless — ถ้าไม่มี state
//           ก็ไม่ต้องจ่ายค่าความซับซ้อนของ Stateful
// [จำเป็น?] MaterialApp จำเป็น (วิดเจ็ต Material อย่าง Scaffold/AppBar ต้องการมัน
//           อยู่เหนือขึ้นไปใน tree) · การแยกเป็นคลาส MyApp เป็นแค่ธรรมเนียม
// [ข้อดี]   const constructor ทำให้ Flutter ข้ามการสร้างใหม่ได้เมื่อไม่มีอะไรเปลี่ยน
class Ch07LabApp extends StatelessWidget {
  const Ch07LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// แบบฝึกหัด 1: แปลง Stateless → Stateful
// ---------------------------------------------------------------------------
// [คืออะไร] StatefulWidget "ตัววิดเจ็ต" — ยังคง immutable เหมือน Stateless
//           หน้าที่หลักมีอย่างเดียวคือสร้างออบเจกต์ State ผ่าน createState()
// [ทำไม]   MyHomePage ต้องเก็บ _counter ที่เปลี่ยนได้ แต่วิดเจ็ตเปลี่ยนค่าไม่ได้
//           จึงแยกข้อมูลที่เปลี่ยนได้ไปไว้ในคลาส State (อยู่ยาวกว่าตัววิดเจ็ต
//           ซึ่งอาจถูกสร้างใหม่บ่อย ๆ โดย Flutter)
// [จำเป็น?] จำเป็น ถ้าวิดเจ็ตนี้ต้องมีข้อมูลที่เปลี่ยนและกระทบหน้าจอ
// [ข้อเสีย] โค้ดยาวกว่า Stateless (2 คลาส) และ State object ต้องดูแลวงจรชีวิต
//           → ใช้ Stateful เฉพาะเมื่อมี state จริง ๆ
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // [คืออะไร] createState() คือเมธอดบังคับของ StatefulWidget
  // [ทำไม]   เป็นช่องทางที่ Flutter ใช้ขอ State object (เรียกครั้งเดียวต่อวิดเจ็ตหนึ่งตำแหน่งใน tree)
  // [ข้อสอบ] สร้าง "คู่" ระหว่างวิดเจ็ตกับ State: State<MyHomePage> ต้องตรงกับคลาสวิดเจ็ต
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// [คืออะไร] คลาส State — เก็บตัวแปร state + มีเมธอด build()
// [ทำไม]   ขึ้นต้นด้วย _ เพื่อให้เป็น private ของไฟล์นี้ (ไม่มีใครภายนอกควรสร้าง State ตรง ๆ)
class _MyHomePageState extends State<MyHomePage> {
  // -------------------------------------------------------------------------
  // แบบฝึกหัด 2: ตัวแปร state
  // -------------------------------------------------------------------------
  // [คืออะไร] ตัวแปร state ชนิด int — อยู่ใน State ไม่ใช่ในตัววิดเจ็ต และอยู่นอก build()
  // [ทำไม]   ถ้าประกาศใน build() มันจะถูกรีเซ็ตเป็น 0 ทุกครั้งที่ build ถูกเรียก
  // [ข้อดี]   private (_) → ป้องกันโค้ดอื่นแก้ค่าโดยไม่ผ่านเมธอดที่ควบคุม
  int _counter = 0;

  // [คืออะไร] ตัวสลับแสดง/ซ่อน ColorChanger เพื่อทดสอบ dispose (ดูแบบฝึกหัด 5)
  bool _showColorChanger = true;

  // [คืออะไร] เมธอดที่แก้ state โดยครอบด้วย setState
  // [ทำไม]   setState บอก Flutter ว่า "ข้อมูลเปลี่ยนแล้ว" → mark ว่า dirty →
  //           เรียก build() ใหม่ในเฟรมถัดไป
  // [จำเป็น?] จำเป็นมาก ถ้าเขียนแค่ _counter++ ตัวแปรจะเปลี่ยนแต่หน้าจอไม่ขยับ
  //           (ลองดู: ลบ setState ออกแล้วกดปุ่ม)
  // [ข้อควรระวัง] setState ใช้ได้เฉพาะในคลาส State เท่านั้น
  void _incrementCounter() {
    setState(() {
      // แก้ค่า "ภายใน" callback — callback ถูกรันทันที แล้วค่อย schedule build
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] build() ถูกเรียกครั้งแรก + ทุกครั้งที่ setState
    // [ทำไม]   UI = ฟังก์ชันของ state → สร้าง UI ใหม่จากค่า state ปัจจุบันเสมอ
    // [ข้อควรระวัง] build ต้องเร็วและไม่มี side effect (ห้ามแก้ state ในนี้
    //           หรือเริ่มงานหนักในนี้ เพราะถูกเรียกบ่อยมาก)
    return Scaffold(
      appBar: AppBar(
        title: const Text('ปฏิบัติการบทที่ 7 - State'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- แบบฝึกหัด 2 ----
          // [ข้อสอบ] Text นี้ "ห้ามเป็น const" เพราะค่าเปลี่ยนตาม _counter
          //          (ถ้าใส่ const คอมไพเลอร์จะฟ้อง เพราะ $_counter ไม่ใช่ค่าคงที่)
          Text(
            'ค่าตัวนับ: $_counter',
            style: const TextStyle(fontSize: 24), // ส่วนที่ไม่เปลี่ยนใส่ const ได้
          ),
          const Text(
            'กดปุ่ม + มุมขวาล่าง · setState ทำให้ MyHomePage.build ทำงานใหม่',
            style: TextStyle(fontSize: 12),
          ),
          const Divider(height: 32),

          // ---- แบบฝึกหัด 5: สลับเพื่อให้ ColorChanger ถูก dispose ----
          // [คืออะไร] SwitchListTile ที่ควบคุม _showColorChanger
          // [ทำไม]   dispose() จะถูกเรียกเมื่อ State "ถูกถอดออกจาก tree" เท่านั้น
          //          การซ่อนวิดเจ็ตด้วย if จึงเป็นวิธีเห็น dispose ในแอปเล็ก ๆ
          //          (ดูข้อความ "dispose: ..." ใน Debug Console)
          SwitchListTile(
            title: const Text('แสดง ColorChanger'),
            subtitle: const Text('ปิด → dispose() ทำงาน · เปิด → initState() ทำงานใหม่'),
            value: _showColorChanger,
            onChanged: (v) => setState(() => _showColorChanger = v),
          ),

          // ---- แบบฝึกหัด 3-5 ----
          // [คืออะไร] collection-if: ใส่วิดเจ็ตใน list เมื่อเงื่อนไขจริง
          // [ข้อสอบ] const ColorChanger() เป็นอินสแตนซ์เดิมทุกครั้งที่ MyHomePage rebuild
          //          Flutter เห็นว่า "เหมือนเดิม" จึงไม่ rebuild ColorChanger
          //          (นี่คือเหตุผลที่ควรใส่ const) — กดปุ่ม + แล้วสีไม่เปลี่ยนตาม
          if (_showColorChanger) const ColorChanger(),
          const Divider(height: 32),

          // ---- แบบฝึกหัด 6 (ทางเลือก) ----
          const LiftingStateSection(),
        ],
      ),

      // [คืออะไร] FloatingActionButton เรียก _incrementCounter
      // [ทำไม]   ส่ง "ชื่อเมธอด" (ไม่ใส่วงเล็บ) เป็น callback ให้ onPressed
      //          ถ้าเขียน _incrementCounter() จะเรียกทันทีตอน build ไม่ใช่ตอนกด
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
