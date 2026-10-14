import 'package:flutter/material.dart';

// ============================================================================
// ความท้าทายท้ายแลปบทที่ 9
//   ข้อ 1: คลาส DetailArgs + onGenerateRoute (ดู navigate_app.dart)
//   ข้อ 2: PopScope กันผู้ใช้ทิ้งข้อความที่พิมพ์ค้าง
//   ข้อ 3: Login → pushReplacement · Logout → pushAndRemoveUntil
// ============================================================================

// ---------------------------------------------------------------------------
// ข้อ 1: คลาส arguments + หน้าที่รับค่าทาง constructor
// ---------------------------------------------------------------------------

// [คืออะไร] คลาสห่อ arguments ของ route
// [ทำไม]   Map<String, String> พิมพ์คีย์ผิดแล้วคอมไพเลอร์ไม่เตือน
//          คลาสมีชื่อฟิลด์/ชนิดชัดเจน → ผิดแล้วรู้ตั้งแต่เขียน
// [ข้อดี]   `const` ได้ · ใช้เป็นสัญญาระหว่างผู้เรียกกับด่าน onGenerateRoute
class DetailArgs {
  final String itemId;
  final String message;
  const DetailArgs({required this.itemId, required this.message});
}

// [คืออะไร] หน้ารายละเอียดที่รับข้อมูลทาง constructor (ไม่ต้องรู้จัก ModalRoute เลย)
// [ข้อดี]   ทดสอบง่าย · ใช้งานซ้ำนอกระบบ named routes ได้
class TypedDetailScreen extends StatelessWidget {
  static const routeName = '/typed-detail';

  final String itemId;
  final String message;

  const TypedDetailScreen({super.key, required this.itemId, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ไอเท็ม: $itemId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ได้รับ: $message'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ย้อนกลับ'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ข้อ 2: PopScope
// ---------------------------------------------------------------------------
// ปัญหา: ผู้ใช้พิมพ์บันทึกยาว ๆ แล้วเผลอปัดกลับ → ข้อความหายทันที
// วิธีแก้: ดัก "การย้อนกลับ" ทุกช่องทาง (ลูกศร AppBar, ปุ่มกลับ Android, ปัด iOS)
class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  // [คืออะไร] state: ผู้ใช้พิมพ์อะไรไปแล้วหรือยัง
  // [ทำไม]   ต้องเป็น state เพราะ PopScope.canPop ต้องเปลี่ยนตามค่านี้ (setState บทที่ 7)
  bool _dirty = false;

  // [คืออะไร] ถาม "ทิ้งการแก้ไขไหม" ด้วย dialog
  // [ข้อสอบ] showDialog ก็คือการ push route ใหม่ขึ้น stack เช่นกัน
  //          ปุ่มใน dialog จึงปิดด้วย Navigator.pop(context, ค่า) — กลไกเดียวกับแบบฝึกหัด 3
  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ทิ้งการแก้ไข?'),
        content: const Text('ข้อความที่พิมพ์ไว้จะหายไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('แก้ต่อ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ทิ้ง'),
          ),
        ],
      ),
    );
    // แตะนอกกรอบ dialog → null → ถือว่า "ไม่ทิ้ง" (ปลอดภัยไว้ก่อน)
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] PopScope = ตัวดักการ pop (แทน WillPopScope ที่เลิกใช้แล้ว)
    return PopScope(
      // [ทำไม]   "บอกล่วงหน้า" ว่าตอนนี้ย้อนกลับได้ไหม — ท่าปัดของ iOS/predictive back ของ Android
      //          ต้องรู้ตั้งแต่ก่อนนิ้วเริ่มลาก จึงตัดสินใจตอนกดไม่ทัน
      canPop: !_dirty,

      // [คืออะไร] ถูกเรียกทุกครั้งที่มีความพยายามย้อนกลับ
      //   didPop = true  → ย้อนกลับไปแล้ว (ไม่ต้องทำอะไร)
      //   didPop = false → ถูกกันไว้เพราะ canPop เป็น false → เราถามผู้ใช้ แล้วสั่ง pop เอง
      // [ข้อสอบ] ใช้ onPopInvokedWithResult (ของเก่า onPopInvoked ถูกแทนที่แล้ว)
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        // เช็ก context.mounted ก่อนใช้ context หลัง await
        if (discard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('แก้ไขบันทึก')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'พิมพ์อะไรสักอย่าง แล้วลองกดย้อนกลับ',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) {
              // เรียก setState เฉพาะครั้งแรกที่เปลี่ยนจาก false → true
              // [ข้อดี] ไม่ rebuild ทุกตัวอักษรที่พิมพ์
              if (!_dirty) setState(() => _dirty = true);
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ข้อ 3: Login / Logout กับการจัดการ stack
// ---------------------------------------------------------------------------
//  stack ที่เริ่ม:            [เมนู]
//  เริ่มโฟลว์ล็อกอิน (push):   [เมนู, Login]
//  กดเข้าสู่ระบบ (pushReplacement): [เมนู, Dashboard]   ← Login ถูกแทนที่
//  ไปหน้าลึก (push):          [เมนู, Dashboard, Profile]
//  ออกจากระบบ (pushAndRemoveUntil): [เมนู, Login]       ← ล้างหน้าที่ผู้ใช้เดิมเห็น
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // [คืออะไร] pushReplacement = push หน้าใหม่ + เอาหน้าปัจจุบัน (Login) ออกพร้อมกัน
            // [ทำไม]   ถ้าใช้ push ธรรมดา กดกลับจาก Dashboard แล้วจะเจอหน้ากรอกรหัสผ่านอีก
            // [ข้อดี]   stack สั้นลง ไม่มีหน้าที่ไม่ควรย้อนกลับไปหา
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
          child: const Text('เข้าสู่ระบบ'),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หน้าหลักหลังล็อกอิน')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              // push ลงไปอีกชั้น เพื่อให้ stack ลึกขึ้นก่อนทดลองออกจากระบบ
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const _ProfileScreen()),
              ),
              child: const Text('ไปหน้าโปรไฟล์ (ลึกอีกชั้น)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // [คืออะไร] pushAndRemoveUntil = push หน้าใหม่ แล้วไล่เอาหน้าด้านล่างออกทีละหน้า
            //          จนกว่าฟังก์ชันเงื่อนไขจะตอบ true
            // [ทำไม]   ออกจากระบบต้องล้างหน้าที่มีข้อมูลผู้ใช้เดิมทิ้ง ไม่งั้นผู้ใช้คนต่อไป
            //          กดย้อนกลับแล้วเห็นข้อมูลของคนก่อน
            // [ข้อสอบ] (route) => false  = ล้างทั้ง stack ไม่เหลือหน้าไหน (แอปจริงที่ Login เป็นหน้าแรก)
            //          (route) => route.isFirst = เก็บหน้าล่างสุดไว้ ← ที่นี่เก็บ "เมนูแลป"
            //          ไว้ เพื่อให้คุณกลับออกจากแลปได้ ไม่ติดอยู่หน้า Login
            // [ข้อดี]   เคลียร์ stack ได้ในคำสั่งเดียว
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => route.isFirst,
            );
          },
          child: const Text('ออกจากระบบ'),
        ),
      ),
    );
  }
}
