import 'package:flutter/material.dart';

import 'challenge_screens.dart';
import 'home_screen.dart';
import 'named_detail_screen.dart';

// ============================================================================
// แลปบทที่ 9: การนำทางระหว่างหน้าจอ  (ไฟล์นี้ = main.dart ของโปรเจกต์ navigate_route)
//
// ไฟล์ในแลปนี้:
//   navigate_app.dart        ← (ไฟล์นี้) ตั้งค่า routes ทั้งหมด
//   home_screen.dart         ← เมนูแบบฝึกหัด 1-5 + ความท้าทาย 1-3
//   detail_screen.dart       ← แบบฝึกหัด 1-3: ส่งข้อมูลผ่าน constructor / pop พร้อมผลลัพธ์
//   named_detail_screen.dart ← แบบฝึกหัด 4-5: named route + arguments (Map)
//   challenge_screens.dart   ← ความท้าทาย: DetailArgs, PopScope, Login/Logout
//
// ภาพรวมที่ต้องเข้าใจ:
//   Navigator จัดการ "stack ของหน้าจอ"  →  push = วางหน้าใหม่บนสุด · pop = เอาหน้าบนสุดออก
//   ส่งข้อมูล "ไป"  : constructor (ค่าเริ่มต้นที่ควรเลือก) หรือ arguments ของ named route
//   ส่งข้อมูล "กลับ": Navigator.pop(context, ผลลัพธ์)  ← ผู้เรียกใช้ await รับ
// ============================================================================

class Ch09LabApp extends StatelessWidget {
  const Ch09LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // [คืออะไร] ชื่อ route แรกที่แอปเปิดขึ้น (ใช้แทน home:)
      // [ข้อสอบ] ห้ามใช้ home: ร่วมกับ initialRoute: '/' ที่ซ้ำกัน — ใช้อย่างใดอย่างหนึ่ง
      initialRoute: HomeScreen.routeName,

      // [คืออะไร] แผนที่ "ชื่อ route → ฟังก์ชันสร้างหน้า"
      // [ทำไม]   รวมรายชื่อหน้าจอไว้ที่เดียว ใช้ค่าคงที่ routeName แทนสตริงลอย ๆ
      //          → พิมพ์ชื่อผิดน้อยลง
      // [ข้อดี]   อ่านง่าย เหมาะกับแอปเล็ก
      // [ข้อเสีย] ส่ง arguments ได้แต่ไม่ถูกตรวจชนิดตอนคอมไพล์ · และ Flutter เองไม่แนะนำ
      //          named routes สำหรับแอปส่วนใหญ่แล้ว (ติดเรื่อง deep link) แต่แอปเล็ก ๆ ยังใช้ได้
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        NamedDetailScreen.routeName: (context) => const NamedDetailScreen(),
        // TypedDetailScreen ไม่อยู่ในนี้ เพราะต้องรับข้อมูลผ่าน constructor
        // → ให้ onGenerateRoute สร้างแทน (ความท้าทายข้อ 1)
      },

      // -----------------------------------------------------------------------
      // ความท้าทายข้อ 1: onGenerateRoute — "ด่านตรวจคนเข้าเมือง"
      // -----------------------------------------------------------------------
      // [คืออะไร] ถูกเรียกเมื่อ pushNamed ด้วยชื่อที่ "ไม่อยู่ใน routes"
      // [ทำไม]   ตรวจชนิดของ arguments ที่จุดเดียว แล้วแกะส่งเข้า constructor ของหน้า
      //          → หน้าปลายทางรับค่าแบบที่คอมไพเลอร์ตรวจได้ ไม่ต้องรู้จัก ModalRoute
      // [ข้อดี]   ปลอดภัยกว่า cast ที่หน้าปลายทาง (ผิดแล้วไปหน้า "ไม่พบหน้า" ไม่ใช่แอปพัง)
      // [ข้อเสีย] โค้ดยาวขึ้นกว่า routes map · การตรวจชนิดยังเกิดตอนรัน (แต่รวมอยู่จุดเดียว)
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        // `args is DetailArgs` ทั้งตรวจและ "promote" ชนิดในขั้นเดียว
        // → ในบล็อก if เรียก args.itemId ได้เลยโดยไม่ต้อง cast
        if (settings.name == TypedDetailScreen.routeName && args is DetailArgs) {
          return MaterialPageRoute(
            // [ข้อสอบ] ใส่ settings: settings เพื่อให้ route จำชื่อ/arguments ตัวเองได้
            //          (จำเป็นเมื่อจะกลับมาหาด้วยชื่อ เช่น ModalRoute.withName)
            settings: settings,
            builder: (context) => TypedDetailScreen(
              itemId: args.itemId,
              message: args.message,
            ),
          );
        }
        // [ทำไม] คืน null = "ฉันไม่รู้จัก" → Flutter ส่งต่อให้ onUnknownRoute
        return null;
      },

      // [คืออะไร] ด่านสุดท้ายเมื่อหา route ไม่เจอ
      // [จำเป็น?] ไม่จำเป็นต่อการทำงานปกติ · แต่ถ้าไม่มีและชื่อไม่ตรง แอปจะ error
      //          "Could not find a generator for route"
      // [ลำดับค้นหา] routes → onGenerateRoute → onUnknownRoute → error
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('ไม่พบหน้า')),
          body: Center(child: Text('ไม่มีหน้าชื่อ ${settings.name}\nหรือส่ง arguments ไม่ครบ')),
        ),
      ),
    );
  }
}
