import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ส่วนที่ 3: import แพ็กเกจ provider

import '../providers/counter_provider.dart'; // import model ของเรา

// ============================================================================
// แลปบทที่ 10: Refactor ตัวนับด้วย Provider  (ผลลัพธ์หลัง refactor)
//
// ไฟล์ในแลปนี้:
//   providers/counter_provider.dart ← ส่วนที่ 2: ChangeNotifier model
//   provider_counter_app.dart       ← (ไฟล์นี้) ส่วนที่ 3-5, 7: provide + consume
//   setstate_counter_app.dart       ← เวอร์ชัน "ก่อน" refactor (ไว้เทียบ)
//
// 4 ขั้นตอนใหญ่ของ Provider (จำให้ได้ ข้อสอบถามบ่อย):
//   1. สร้าง Model (extends ChangeNotifier + notifyListeners)
//   2. Provide : ห่อ tree ด้วย ChangeNotifierProvider(create: ...)
//   3. Consume : อ่านด้วย context.watch<T>() ใน build  → rebuild เมื่อเปลี่ยน
//   4. Trigger : สั่งงานด้วย context.read<T>() ใน onPressed → ไม่ rebuild
//
// pubspec.yaml ต้องมี  provider: ^6.1.5+1  แล้วสั่ง flutter pub get
// ============================================================================

// ---------------------------------------------------------------------------
// ส่วนที่ 3: Provide the State  (ใน main.dart ของแลปจริงคือฟังก์ชัน main())
// ---------------------------------------------------------------------------
// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => CounterProvider(),
//       child: const MyApp(),
//     ),
//   );
// }
//
// ที่นี่ main() ถูกแทนด้วยวิดเจ็ตนี้ (เพราะแลปรันอยู่ภายในแอปทบทวน)
//
// [คืออะไร] ChangeNotifierProvider = สร้าง CounterProvider หนึ่งอินสแตนซ์
//          แล้ว "แจกจ่าย" ให้ทุกวิดเจ็ตที่อยู่ใต้มันใน tree
// [ทำไม]   วางไว้ "เหนือ" วิดเจ็ตทุกตัวที่ต้องใช้ state นี้ — ที่นี่เหนือ MaterialApp
//          เพื่อให้ทุกหน้าใน Navigator เข้าถึงได้ (วางต่ำเกินไป = บางหน้าหาไม่เจอ)
// [ข้อสอบ] create: ใช้สร้างอินสแตนซ์ใหม่ + provider จะ dispose ให้เองเมื่อออกจาก tree
//          (ถ้าอินสแตนซ์มีอยู่แล้ว ให้ใช้ ChangeNotifierProvider.value แทน)
// [ข้อดี]   ไม่ต้องส่ง state ผ่าน constructor ทีละชั้น (แก้ปัญหา "lifting state up" ที่ยุ่ง)
class Ch10LabApp extends StatelessWidget {
  const Ch10LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Provider Counter Lab',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const MyHomePage(title: 'Provider Counter'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MyHomePage
// ---------------------------------------------------------------------------
// [ทำไม]   เปลี่ยนจาก StatefulWidget เป็น StatelessWidget: หลัง refactor หน้านี้
//          ไม่มี state ของตัวเองแล้ว (state ย้ายไป CounterProvider) → ไม่ต้องมีคลาส State
//          และไม่ต้องใช้ setState (ตำราคงเป็น Stateful ไว้ แต่ไม่จำเป็น)
// [ข้อดี]   โค้ดสั้นลง · ใช้ const ได้
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------------
    // ส่วนที่ 4: Consume State ด้วย context.watch
    // -----------------------------------------------------------------------
    // [คืออะไร] watch<CounterProvider>() ทำ 3 อย่างพร้อมกัน:
    //   (1) หา CounterProvider ที่ "ใกล้ที่สุด" เหนือขึ้นไปใน tree
    //   (2) คืนอินสแตนซ์นั้นให้
    //   (3) "สมัครรับฟัง" → เมื่อ notifyListeners() ถูกเรียก build ของวิดเจ็ตนี้ทำงานใหม่
    // [ข้อสอบ] ใช้ watch ใน build() เท่านั้น ห้ามใช้ใน onPressed/callback
    // [ข้อเสีย] เรียกที่บนสุดของ build = ทั้งเมธอด build (Scaffold, AppBar ฯลฯ) rebuild
    //          ทุกครั้ง ทั้งที่เปลี่ยนแค่ตัวเลขตัวเดียว → บท 11 แก้ด้วย Consumer / select
    final counterValue = context.watch<CounterProvider>().count;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$counterValue', // แสดงค่าจาก Provider (ไม่ใช่ตัวแปรในหน้านี้อีกแล้ว)
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // ส่วนที่ 7 (ทางเลือก): วิดเจ็ตที่สองที่ watch provider ตัวเดียวกัน
            const CounterDisplay(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ---------------------------------------------------------------------
        // ส่วนที่ 5: Trigger ด้วย context.read
        // ---------------------------------------------------------------------
        // [คืออะไร] read<T>() ดึงอินสแตนซ์ "ครั้งเดียว" โดย "ไม่สมัครรับฟัง"
        // [ทำไม]   ปุ่มแค่ต้อง "สั่ง" increment() ไม่จำเป็นต้อง rebuild ตามค่าตัวนับ
        // [ข้อสอบ] กฎจำ: build → watch · callback (onPressed ฯลฯ) → read
        // [ข้อเสีย/ข้อควรระวัง] ถ้าใช้ watch ใน onPressed จะ error
        //          (watch ใช้ได้เฉพาะระหว่าง build) · ถ้าใช้ read ใน build เพื่อ "แสดงค่า"
        //          UI จะไม่อัปเดตตาม
        onPressed: () => context.read<CounterProvider>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ส่วนที่ 7: CounterDisplay — พิสูจน์ว่า "state ถูกแชร์"
// ---------------------------------------------------------------------------
// [คืออะไร] วิดเจ็ต Stateless แยกต่างหาก ที่ watch CounterProvider ตัวเดียวกัน
// [ทำไม]   เมื่อกดปุ่ม ค่าทั้งสองจุดบนจอเปลี่ยนพร้อมกัน ทั้งที่ไม่มีการส่งค่าผ่าน
//          constructor เลย → นี่คือพลังของการมี state กลางหนึ่งเดียว
// [ข้อดี]   วางไว้ลึกกี่ชั้นก็ได้ เข้าถึง state ตรง ๆ ไม่ต้องไล่ส่งค่า
// [ข้อสอบ] ดู Debug Console: "CounterDisplay rebuild" ปรากฏทุกครั้งที่กดปุ่ม
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterProvider>().count;

    // ใส่ debugPrint ใน build เพื่อ "วัด" ว่า build ทำงานเมื่อไร (เทคนิคตรวจ rebuild บท 11)
    // [ข้อควรระวัง] เป็นแค่เครื่องมือดีบัก — ห้ามให้ build มี side effect ที่เปลี่ยน state
    debugPrint('CounterDisplay rebuild: $count');
    return Text(
      'ค่าจาก Provider: $count',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
