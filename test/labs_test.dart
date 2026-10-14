import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_final_app/chapters/ch07/ch07_labs.dart';
import 'package:review_final_app/chapters/ch08/ch08_labs.dart';
import 'package:review_final_app/chapters/ch09/ch09_labs.dart';
import 'package:review_final_app/chapters/ch10/ch10_labs.dart';
import 'package:review_final_app/chapters/ch11/ch11_labs.dart';
import 'package:review_final_app/chapters/ch12/ch12_labs.dart';
import 'package:review_final_app/chapters/ch13/ch13_labs.dart';
import 'package:review_final_app/chapters/ch12/services/api_service.dart';
import 'package:review_final_app/chapters/registry.dart';
import 'package:review_final_app/core/lab.dart';
import 'package:review_final_app/core/lab_screen.dart';
import 'package:review_final_app/main.dart';

Future<void> _openLab(WidgetTester tester, LabChapter c, int i) async {
  tester.view.physicalSize = const Size(900, 4000); // สูงพอให้ ListView สร้างครบ
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  if (c.number == 13) {
    // แลปบท 13 เรียก sqflite จริง (ทดสอบบน Android emulator แยกต่างหาก) — ในเทสต์จำลองเป็น Linux
    // เพื่อให้ SqfliteGuard แสดงข้อความแทนการเรียก plugin ที่ไม่มีในเครื่องทดสอบ
    // (ต้องคืนค่าเป็น null ก่อนจบเทสต์ — ดู _resetPlatform ที่ท้ายแต่ละเทสต์ที่เปิดบท 13)
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  }
  // ล้างแคช asset: Future ที่แคชไว้จากเทสต์ก่อนหน้าผูกกับ FakeAsync zone เก่า ทำให้ pumpAndSettle ค้าง
  // (เป็นเรื่องของสภาพแวดล้อมเทสต์เท่านั้น แอปจริงไม่มีปัญหา)
  (rootBundle as CachingAssetBundle).clear();
  await tester.pumpWidget(const SizedBox()); // เคลียร์ tree เดิม เพื่อให้ State ถูกสร้างใหม่ทุกครั้ง
  await tester.pumpWidget(MaterialApp(home: LabScreen(chapter: c, lab: c.labs[i])));
  await tester.pump();
}

/// เปิดแลปบท 12 ด้วยโหมดเครือข่ายที่กำหนด
/// (ต้องเคลียร์ tree เดิมก่อนตั้งโหมด เพราะแถบโหมดรีเซ็ตเป็น real ตอน dispose)
Future<void> _openCh12(WidgetTester tester, int labIndex, LabNetworkMode mode) async {
  await tester.pumpWidget(const SizedBox());
  labNetworkMode = mode;
  await _openLab(tester, chapter12, labIndex);
}

void _resetPlatform() => debugDefaultTargetPlatformOverride = null;

void main() {
  // ทุกแลปในทุกบท: เปิดได้ และทุกไฟล์ซอร์สโหลดจาก asset ได้
  for (final c in allChapters) {
    for (var i = 0; i < c.labs.length; i++) {
      final lab = c.labs[i];
      testWidgets('${c.label} ${lab.id}: รันได้และซอร์สทุกไฟล์โหลดได้', (tester) async {
        await _openLab(tester, c, i);
        expect(tester.takeException(), isNull);

        for (final f in lab.files) {
          await tester.ensureVisible(find.text(f.split('/').last));
          await tester.tap(find.text(f.split('/').last));
          await tester.pumpAndSettle();
          expect(find.textContaining('อ่านไฟล์ไม่ได้'), findsNothing, reason: f);
          // ทุกไฟล์ต้องมีคอมเมนต์แท็กอธิบายอย่างน้อยหนึ่งแท็ก
          // (อ่านจาก asset ตรง ๆ เพราะ ListView สร้างเฉพาะบรรทัดที่เห็น)
          final src = await rootBundle.loadString(f);
          expect(RegExp(r'\[(คืออะไร|ทำไม|จำเป็น\?|ข้อดี|ข้อเสีย)\]').hasMatch(src), isTrue,
              reason: '$f ไม่มีคอมเมนต์แท็กอธิบาย');
        }
        expect(tester.takeException(), isNull);
        _resetPlatform();
      });
    }
  }

  testWidgets('บทที่ 7: กด + แล้วตัวนับเพิ่ม, ซ่อน/แสดง ColorChanger', (tester) async {
    await _openLab(tester, chapter07, 0);

    expect(find.text('ค่าตัวนับ: 0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('ค่าตัวนับ: 1'), findsOneWidget);

    expect(find.text('แตะฉัน!'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.text('แตะฉัน!'), findsNothing);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.text('แตะฉัน!'), findsOneWidget);

  });

  testWidgets('บทที่ 8: validator แสดง error และฟอร์มที่ถูกต้องผ่าน', (tester) async {
    await _openLab(tester, chapter08, 0);

    await tester.tap(find.text('ล็อกอิน'));
    await tester.pump();
    expect(find.text('กรุณาป้อนอีเมลของคุณ'), findsOneWidget);
    expect(find.text('กรุณาป้อนรหัสผ่านของคุณ'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('ล็อกอิน'));
    await tester.pump();
    expect(find.text('กรุณาป้อนที่อยู่อีเมลที่ถูกต้อง'), findsOneWidget);
    expect(find.text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'), findsOneWidget);

    // อีเมลมีช่องว่างหัวท้าย ต้องผ่านและถูก trim
    await tester.enterText(find.byType(TextFormField).at(0), '  you@example.com ');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('ล็อกอิน'));
    await tester.pump();
    expect(find.text('ล็อกอินสำเร็จ! อีเมล: you@example.com'), findsOneWidget);
    // รหัสผ่านถูกล้างหลังส่งสำเร็จ
    expect(find.text('123456'), findsNothing);
  });

  testWidgets('บทที่ 9: push/pop, ส่งข้อมูล, ผลลัพธ์กลับ, named route', (tester) async {
    await _openLab(tester, chapter09, 0);

    await tester.tap(find.text('ไปที่รายละเอียด'));
    await tester.pumpAndSettle();
    expect(find.text('รายละเอียดอยู่ที่นี่'), findsOneWidget);
    await tester.tap(find.text('ย้อนกลับ'));
    await tester.pumpAndSettle();
    expect(find.text('หน้าหลัก'), findsOneWidget);

    // ผลลัพธ์กลับผ่าน pop
    await tester.tap(find.text('ไปแล้วรอผลลัพธ์กลับมา'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ย้อนกลับ'));
    await tester.pumpAndSettle();
    expect(find.text('ผลลัพธ์: สำเร็จ! ข้อมูลจากรายละเอียด'), findsOneWidget);

    // named route + arguments
    await tester.tap(find.text('pushNamed + arguments (Map)'));
    await tester.pumpAndSettle();
    expect(find.text('ไอเท็ม: ARG-789'), findsOneWidget);
    expect(find.text('ได้รับ: ข้อมูลจาก Named Route Args'), findsOneWidget);
    await tester.tap(find.text('ย้อนกลับ'));
    await tester.pumpAndSettle();

    // onGenerateRoute: ถูกต้อง และ onUnknownRoute เมื่อไม่ส่ง arguments
    await tester.tap(find.text('ส่ง DetailArgs (ถูกต้อง)'));
    await tester.pumpAndSettle();
    expect(find.text('ไอเท็ม: ARG-001'), findsOneWidget);
    await tester.tap(find.text('ย้อนกลับ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ไม่ส่ง arguments (ทดสอบ onUnknownRoute)'));
    await tester.pumpAndSettle();
    expect(find.text('ไม่พบหน้า'), findsOneWidget);
  });

  testWidgets('บทที่ 9: PopScope ถามก่อนทิ้ง และ login/logout จัดการ stack', (tester) async {
    await _openLab(tester, chapter09, 0);

    await tester.tap(find.text('เปิดหน้าแก้ไขบันทึก'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ร่างบันทึก');
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('ทิ้งการแก้ไข?'), findsOneWidget);
    await tester.tap(find.text('แก้ต่อ'));
    await tester.pumpAndSettle();
    expect(find.text('แก้ไขบันทึก'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทิ้ง'));
    await tester.pumpAndSettle();
    expect(find.text('หน้าหลัก'), findsOneWidget);

    await tester.tap(find.text('เริ่มโฟลว์ล็อกอิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('หน้าหลักหลังล็อกอิน'), findsOneWidget);
    // pushReplacement: กดกลับต้องไม่เจอหน้า Login
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('หน้าหลัก'), findsOneWidget);
  });

  testWidgets('บทที่ 10: state เดียวแชร์สองจุด', (tester) async {
    await _openLab(tester, chapter10, 1);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('ค่าจาก Provider: 0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('ค่าจาก Provider: 2'), findsOneWidget);
  });

  testWidgets('บทที่ 11: แก้ item แล้วหน้ารายการอัปเดตผ่าน Provider (editor)', (tester) async {
    await _openLab(tester, chapter11, 0);
    await tester.tap(find.text('Dell XPS 15'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'Intel Core Ultra 7, 64GB RAM');
    await tester.tap(find.text('บันทึกการเปลี่ยนแปลง'));
    await tester.pumpAndSettle();
    expect(find.text('Intel Core Ultra 7, 64GB RAM'), findsOneWidget);
  });

  testWidgets('บทที่ 11: shop — validator ราคา และบันทึกสำเร็จ', (tester) async {
    await _openLab(tester, chapter11, 1);
    await tester.tap(find.text('ปากกาสีน้ำเงิน'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();
    expect(find.text('ราคาต้องมากกว่า 0'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), '99.5');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(find.text('฿99.50'), findsOneWidget);
  });

  testWidgets('บทที่ 11: rebuild lab — watch vs select', (tester) async {
    await _openLab(tester, chapter11, 2);
    // watch: ทุกส่วน build ×1 แล้วเพิ่มเป็น ×2 พร้อมกัน
    expect(find.text('ชื่อเล่น: build ×1'), findsOneWidget);
    await tester.tap(find.text('เปลี่ยนชื่อเล่น'));
    await tester.pump();
    expect(find.text('ชื่อเล่น: build ×2'), findsOneWidget);
    expect(find.text('รูปโปรไฟล์: build ×2'), findsOneWidget);

    // select: เปลี่ยนสีรูปไม่ทำให้ชื่อเล่น rebuild
    await tester.tap(find.text('4 select'));
    await tester.pump();
    expect(find.text('ชื่อเล่น (select): build ×1'), findsOneWidget);
    await tester.tap(find.text('เปลี่ยนสีรูป'));
    await tester.pump();
    expect(find.text('ชื่อเล่น (select): build ×1'), findsOneWidget);
    await tester.tap(find.text('เปลี่ยนชื่อเล่น'));
    await tester.pump();
    expect(find.text('ชื่อเล่น (select): build ×2'), findsOneWidget);
  });

  testWidgets('บทที่ 12: FutureBuilder 3 สถานะ', (tester) async {
    await _openLab(tester, chapter12, 0);
    expect(find.text('กำลังโหลดข้อมูล...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('สำเร็จ! ได้รับข้อมูล: ข้อมูลจากการทำงานที่ใช้เวลานาน'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('รันใหม่'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('เกิดข้อผิดพลาด: Exception: เกิดข้อผิดพลาดโดยตั้งใจ'), findsOneWidget);
  });

  testWidgets('บทที่ 12: แปลง error เป็น ApiException (500 ลองใหม่ได้ / 404 ลองใหม่ไม่ได้)', (tester) async {
    await _openCh12(tester, 1, LabNetworkMode.server500);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('เซิร์ฟเวอร์ขัดข้องชั่วคราว โปรดลองอีกครั้ง'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsOneWidget);

    labNetworkMode = LabNetworkMode.notFound;
    await tester.tap(find.text('ลองใหม่'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('ไม่พบข้อมูลที่ร้องขอ (รหัส 404)'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsNothing);

    // เปิดแลปใหม่ด้วยโหมดอื่น (ไม่พึ่งท่าลากรีเฟรชในเทสต์)
    await _openCh12(tester, 1, LabNetworkMode.badJson);
    await tester.pump(const Duration(milliseconds: 50));
    // body ที่ได้ผ่าน compute (isolate จริง) จึงต้องให้เวลาจริง
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('รูปแบบข้อมูลที่ได้รับไม่ถูกต้อง'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsNothing);

    await _openCh12(tester, 1, LabNetworkMode.offline);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('เชื่อมต่ออินเทอร์เน็ตไม่ได้ โปรดตรวจสอบการเชื่อมต่อ'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsOneWidget);
    labNetworkMode = LabNetworkMode.real;
  });

  testWidgets('บทที่ 12: ดึงข้อมูลสำเร็จ (compute) และเข้า Provider', (tester) async {
    await _openCh12(tester, 1, LabNetworkMode.fakeOk);
    // 1) ผ่านเวลาจำลอง (Future.delayed 600ms) 2) compute ใช้ isolate จริง ต้องให้เวลาจริงผ่าน runAsync
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    await tester.pump();
    expect(find.text('รายการจำลองที่ 1'), findsOneWidget);
  });

  testWidgets('บทที่ 12: TodoProvider โหลดผ่าน addPostFrameCallback', (tester) async {
    await _openCh12(tester, 2, LabNetworkMode.fakeOk);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    await tester.pump();
    expect(find.text('รายการจำลองที่ 1'), findsOneWidget);

    // โหลดซ้ำแล้วล้มเหลว → ข้อมูลเดิมยังอยู่ + แบนเนอร์
    labNetworkMode = LabNetworkMode.server500;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('รายการจำลองที่ 1'), findsOneWidget);
    expect(find.textContaining('เซิร์ฟเวอร์ขัดข้องชั่วคราว'), findsOneWidget);
    labNetworkMode = LabNetworkMode.real;
  });

  testWidgets('บทที่ 13: บนแพลตฟอร์มที่ไม่รองรับ sqflite แสดงข้อความแทน crash', (tester) async {
    await _openLab(tester, chapter13, 2);
    expect(find.textContaining('รันได้เฉพาะ Android / iOS'), findsOneWidget);
    _resetPlatform();
  });

  testWidgets('หน้าแรก → บท → แลป', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('บทที่ 7: State: StatefulWidget & setState'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('stateful_app (แบบฝึกหัด 1–6)'));
    await tester.pumpAndSettle();
    expect(find.text('ค่าตัวนับ: 0'), findsOneWidget);
  });
}
