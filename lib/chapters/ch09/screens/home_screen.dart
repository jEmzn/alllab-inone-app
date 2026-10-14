import 'package:flutter/material.dart';

import 'challenge_screens.dart';
import 'detail_screen.dart';
import 'named_detail_screen.dart';

// ============================================================================
// HomeScreen — เมนูรวมแบบฝึกหัดทั้งหมด (ในตำราแต่ละแบบฝึกหัดแก้ไฟล์เดิมทับกัน
// ที่นี่แยกเป็นปุ่มเพื่อให้ทดลองเทียบกันได้)
//
// [คืออะไร] StatelessWidget — หน้านี้ไม่เก็บ state เอง (ผลลัพธ์จาก pop แสดงด้วย
//          SnackBar ซึ่งอยู่นอกตัว widget) จึงไม่ต้อง Stateful
// ============================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // [คืออะไร] ชื่อ route ของหน้านี้ เก็บเป็น static const ในคลาสตัวเอง
  // [ทำไม]   ที่เดียวกับที่ใช้ — เรียก HomeScreen.routeName แทนพิมพ์ '/' ซ้ำหลายที่
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หน้าหลัก')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header('แบบฝึกหัดที่ 1: push / pop พื้นฐาน'),
          ElevatedButton(
            // [คืออะไร] Navigator.push(context, MaterialPageRoute(builder: ...))
            //   - Navigator    = ตัวจัดการ stack ของหน้า
            //   - MaterialPageRoute = เส้นทางที่มีแอนิเมชันเปลี่ยนหน้าตามแพลตฟอร์ม
            //   - builder      = ฟังก์ชันสร้างหน้าปลายทาง
            // [ข้อสอบ] ใช้ context ของ widget ที่อยู่ "ใต้" Navigator (MaterialApp)
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailScreen()),
              );
            },
            child: const Text('ไปที่รายละเอียด'),
          ),

          const _Header('แบบฝึกหัดที่ 2: ส่งข้อมูลไปข้างหน้า (constructor)'),
          ElevatedButton(
            // [ทำไม]   ส่งผ่าน constructor = วิธีที่ควรเลือกก่อนเสมอ
            //          เพราะคอมไพเลอร์ตรวจ "ชื่อ + ชนิด" ให้ (ลืมส่ง → คอมไพล์ไม่ผ่าน)
            // [ข้อเสีย] ส่งได้ครั้งเดียวตอน push · ถ้าต้องส่งผ่านหลายหน้า จะยุ่ง
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailScreen(
                    message: 'ข้อมูลส่งมาจากหน้าหลัก!',
                  ),
                ),
              );
            },
            child: const Text('ส่งข้อความไปหน้ารายละเอียด'),
          ),

          const _Header('แบบฝึกหัดที่ 3: ส่งข้อมูลย้อนกลับ (await + pop result)'),
          ElevatedButton(
            // [คืออะไร] Navigator.push เป็น Future → await ได้ ค่าที่ได้คือสิ่งที่
            //          หน้าปลายทางใส่ใน Navigator.pop(context, ค่า)
            // [ทำไม]   เหมาะกับหน้าที่ "ถามคำถามเดียวแล้วส่งคำตอบกลับ" (เลือกสี/ที่อยู่/ยืนยัน)
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailScreen(
                    message: 'กด "ย้อนกลับ" เพื่อส่งผลลัพธ์ หรือกดปุ่มกลับของระบบเพื่อไม่ส่ง',
                    returnsResult: true,
                  ),
                ),
              );

              // [ข้อสอบ] ต้องเช็ก context.mounted ก่อนใช้ context หลัง await ทุกครั้ง
              // [ทำไม]   ระหว่างรอ หน้านี้อาจถูกนำออกจาก tree แล้ว (context ใช้ไม่ได้)
              // [คืออะไร] HomeScreen เป็น Stateless จึงใช้ context.mounted
              //          (ถ้าเป็นคลาส State ใช้ `mounted`)
              if (context.mounted) {
                // [คืออะไร] ผู้ใช้กดปุ่มกลับของระบบ/ปัดขอบ → result เป็น null
                //          จึงต้องรับมือกับ null เสมอ
                final String messageToShow = (result != null && result is String)
                    ? 'ผลลัพธ์: $result'
                    : 'ไม่มีผลลัพธ์ส่งกลับมา';

                // cascade (..) : เรียกหลายเมธอดบนอ็อบเจกต์เดียวกัน
                // removeCurrentSnackBar กันกดซ้ำแล้ว SnackBar ต่อคิวยาว
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(messageToShow)));
              }
            },
            child: const Text('ไปแล้วรอผลลัพธ์กลับมา'),
          ),

          const _Header('แบบฝึกหัดที่ 4-5: Named Routes + arguments'),
          ElevatedButton(
            // [คืออะไร] pushNamed เรียกด้วย "ชื่อ" ที่ลงทะเบียนไว้ใน MaterialApp.routes
            // [ข้อดี]   ไม่ต้อง import คลาสหน้าปลายทางที่จุดเรียก (ลด coupling)
            // [ข้อเสีย] arguments เป็น Object? — ผิดชนิดแล้วไปพังตอนรัน
            onPressed: () {
              Navigator.pushNamed(
                context,
                NamedDetailScreen.routeName,
                arguments: {
                  'id': 'ARG-789',
                  'title': 'ข้อมูลจาก Named Route Args',
                },
              );
            },
            child: const Text('pushNamed + arguments (Map)'),
          ),

          const _Header('ความท้าทายข้อ 1: onGenerateRoute + คลาส DetailArgs'),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                TypedDetailScreen.routeName,
                arguments: const DetailArgs(itemId: 'ARG-001', message: 'ส่งผ่านคลาส DetailArgs'),
              );
            },
            child: const Text('ส่ง DetailArgs (ถูกต้อง)'),
          ),
          OutlinedButton(
            // ลืมส่ง arguments → onGenerateRoute คืน null → onUnknownRoute แสดง "ไม่พบหน้า"
            onPressed: () => Navigator.pushNamed(context, TypedDetailScreen.routeName),
            child: const Text('ไม่ส่ง arguments (ทดสอบ onUnknownRoute)'),
          ),

          const _Header('ความท้าทายข้อ 2: PopScope กันทิ้งข้อความ'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditNoteScreen()),
              );
            },
            child: const Text('เปิดหน้าแก้ไขบันทึก'),
          ),

          const _Header('ความท้าทายข้อ 3: Login → pushReplacement / Logout → pushAndRemoveUntil'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('เริ่มโฟลว์ล็อกอิน'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
