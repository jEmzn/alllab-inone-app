import 'dart:async'; // สำหรับ TimeoutException
import 'dart:convert'; // สำหรับ jsonDecode

import 'package:flutter/foundation.dart'; // สำหรับ compute
import 'package:http/http.dart' as http;

import '../models/todo.dart';

// ============================================================================
// ชั้นบริการเครือข่าย (Service layer) — ฉบับสมบูรณ์ของหัวข้อ 12.5 + 12.6 + 12.7
//
// ทำไมแยกเป็นไฟล์ services/ ?
//   [ทำไม]   หน้าจอไม่ควรรู้จัก http, SocketException, TimeoutException เลย
//            ชั้นนี้ "แปลงข้อผิดพลาดทุกชนิดเป็น ApiException" ที่จุดเดียว
//   [ข้อดี]   เปลี่ยนแหล่งข้อมูล (บท 13: SQLite) แล้วแก้เฉพาะชั้นนี้ · ทดสอบแยกได้
//
// pubspec.yaml ต้องมี  http: ^1.6.0
// Android ต้องประกาศ <uses-permission android:name="android.permission.INTERNET"/>
//   ในไฟล์ manifest ของ main (debug มีให้อยู่แล้ว แต่ release ไม่มี → เชื่อมต่อไม่ได้เงียบ ๆ)
// ============================================================================

// ---------------------------------------------------------------------------
// ข้อผิดพลาดที่ "แอปเข้าใจเอง"
// ---------------------------------------------------------------------------
// [คืออะไร] Exception ของเราเอง เก็บข้อความภาษาคน + บอกว่า "ลองใหม่มีประโยชน์ไหม"
// [ทำไม]   ห้ามโชว์ผู้ใช้ว่า "SocketException: Failed host lookup" — อ่านไม่รู้เรื่อง
//          และไม่รู้ว่าต้องทำอะไรต่อ
// [ข้อสอบ] canRetry: 4xx (คำขอเราผิด) → false เพราะลองซ้ำก็ได้ผลเดิม
//          5xx/timeout/ต่อไม่ติด → true เพราะลองใหม่อาจสำเร็จ
class ApiException implements Exception {
  final String message;
  final bool canRetry;
  const ApiException(this.message, {this.canRetry = true});

  @override
  String toString() => message;
}

// ---------------------------------------------------------------------------
// [เฉพาะแลปนี้] ตัวสลับ "จำลองเครือข่าย" — ไม่มีในตำรา
// ---------------------------------------------------------------------------
// [ทำไม]   เพื่อให้ทดลองทุกสถานะ error ได้โดยไม่ต้องถอดสายเน็ต/รอเซิร์ฟเวอร์ล่มจริง
// [ข้อควรระวัง] โค้ดจริงของคุณไม่ต้องมีส่วนนี้ — มันอยู่ที่ _get() ด้านล่างเท่านั้น
//          ที่เหลือของไฟล์คือโค้ดตามตำราทุกบรรทัด
enum LabNetworkMode { real, fakeOk, offline, slow, server500, notFound, badJson }

LabNetworkMode labNetworkMode = LabNetworkMode.real;

Future<http.Response> _get(Uri uri) {
  switch (labNetworkMode) {
    case LabNetworkMode.real:
      // [คืออะไร] http.get ส่งคำขอ GET · headers บอกว่าอยากได้คำตอบเป็น JSON
      // [ข้อสอบ] ใส่เฉพาะ header ที่ API ต้องการจริง ๆ
      return http.get(uri, headers: {'Accept': 'application/json'});
    case LabNetworkMode.fakeOk:
      // ข้อมูลสำเร็จแบบออฟไลน์ (สร้าง JSON 200 รายการเอง) ไว้ทดลองเมื่อไม่มีอินเทอร์เน็ต
      return Future.delayed(const Duration(milliseconds: 600), () {
        final items = [
          for (var i = 1; i <= 200; i++)
            {'userId': (i - 1) ~/ 20 + 1, 'id': i, 'title': 'รายการจำลองที่ $i', 'completed': i % 3 == 0},
        ];
        // ต้องระบุ charset=utf-8 ไม่งั้น http.Response ตีความ body เป็น latin1 แล้วภาษาไทย error
        return http.Response(
          jsonEncode(items),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
    case LabNetworkMode.offline:
      return Future.error(Exception('จำลอง: ไม่มีสัญญาณ'));
    case LabNetworkMode.slow:
      return Future.delayed(const Duration(seconds: 12), () => http.Response('[]', 200));
    case LabNetworkMode.server500:
      return Future.value(http.Response('', 500));
    case LabNetworkMode.notFound:
      return Future.value(http.Response('', 404));
    case LabNetworkMode.badJson:
      return Future.value(http.Response('<html>Wi-Fi login page</html>', 200));
  }
}

// ---------------------------------------------------------------------------
// หัวข้อ 12.7: ฟังก์ชันแปลง JSON ที่รันใน isolate อื่นผ่าน compute
// ---------------------------------------------------------------------------
// [คืออะไร] แปลงข้อความ JSON → List<Todo>
// [ทำไม]   jsonDecode + fromJson เป็นงานคำนวณ "ซิงโครนัส" บน UI isolate เดียวกับที่วาดหน้าจอ
//          ข้อมูลเป็นพันรายการ → เฟรมค้าง (jank) ตอนโหลดเสร็จ
//          ใส่ async/await ไม่ได้ย้ายงานไปไหน (await แค่รอ) ต้องใช้ compute
// [ข้อสอบ] ฟังก์ชันที่ส่งให้ compute ต้องเป็น "top-level function หรือ static method"
//          (isolate ใหม่ใช้ตัวแปรของอ็อบเจกต์เดิมไม่ได้) และข้อมูลเข้า-ออกต้องส่งข้าม isolate ได้
//          (ข้อความ ตัวเลข List Map ผ่านหมด)
// [ข้อเสีย] การสร้าง isolate มีต้นทุน (ไม่กี่ ms) — ข้อมูลน้อย compute อาจช้ากว่าแปลงตรง ๆ
//          เกณฑ์: เขียนแบบตรง ๆ ก่อน แล้ววัดในโหมด profile ถ้าเฟรมเกิน ~16ms ค่อยย้าย
List<Todo> _parseTodos(String responseBody) {
  final data = jsonDecode(responseBody) as List<dynamic>;
  return data.map((item) => Todo.fromJson(item as Map<String, dynamic>)).toList();
}

// ---------------------------------------------------------------------------
// fetchTodos — ดึงข้อมูลพร้อมรับมือความล้มเหลว (12.5 → 12.6)
// ---------------------------------------------------------------------------
// [คืออะไร] ฟังก์ชัน async คืน Future<List<Todo>>
//          ออกได้ 2 ทาง: สำเร็จ = ได้รายการ · ล้มเหลว = โยน ApiException "เท่านั้น"
Future<List<Todo>> fetchTodos() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos');
  try {
    // [ข้อสอบ] http "ไม่มี timeout ให้โดยปริยาย" ต้องใส่เองทุกคำขอ
    //          ไม่งั้นวงล้อหมุนค้างได้เป็นนาที → .timeout() โยน TimeoutException
    final response = await _get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // ส่งข้อความไปแปลงใน isolate อื่น UI isolate จึงว่างไปวาดเฟรมต่อ
      // [ข้อสอบ] ต้อง `return await` (ไม่ใช่แค่ return) ภายใน try:
      //          ถ้าเขียน `return compute(...)` Future จะหลุดออกจาก try ก่อนทำงานเสร็จ
      //          → FormatException จากการแปลง JSON ไม่ถูก on FormatException ด้านล่างจับ
      //          (ตำราต้นฉบับแสดง compute กับ try-catch แยกกัน ไม่ได้รวมกัน — จุดนี้ผมรวมให้)
      return await compute(_parseTodos, response.body);
    }
    if (response.statusCode >= 500) {
      // ผิดที่ฝั่งเซิร์ฟเวอร์ → ลองใหม่มีโอกาสสำเร็จ
      throw const ApiException('เซิร์ฟเวอร์ขัดข้องชั่วคราว โปรดลองอีกครั้ง');
    }
    // 4xx = คำขอของเราเองไม่ถูกต้อง ลองใหม่ด้วยคำขอเดิมก็ได้ผลเดิม
    throw ApiException(
      'ไม่พบข้อมูลที่ร้องขอ (รหัส ${response.statusCode})',
      canRetry: false,
    );
  } on TimeoutException {
    throw const ApiException('เซิร์ฟเวอร์ตอบกลับช้าเกินไป โปรดลองอีกครั้ง');
  } on FormatException {
    // jsonDecode โยน FormatException เมื่อเนื้อหาไม่ใช่ JSON
    // เช่น โดนหน้าล็อกอินของ Wi-Fi สาธารณะคั่นไว้
    throw const ApiException('รูปแบบข้อมูลที่ได้รับไม่ถูกต้อง', canRetry: false);
  } on ApiException {
    // [ข้อสอบ] ต้อง rethrow ก่อน catch (_) ด้านล่าง ไม่งั้นข้อความที่เราตั้งใจใส่
    //          (เช่น เซิร์ฟเวอร์ขัดข้อง) จะถูกกลืนกลายเป็น "เชื่อมต่อไม่ได้"
    rethrow;
  } catch (_) {
    // เหลือกรณีต่อไม่ติด เช่น ไม่มีสัญญาณ/หาชื่อโฮสต์ไม่พบ
    // (บนมือถือคือ SocketException, บนเว็บคือ ClientException)
    // [ข้อเสีย] catch (_) กว้างมาก — JSON ขาดฟิลด์ (TypeError) ก็ตกมาที่นี่ด้วย
    //          แล้วข้อความอาจไม่ตรงสาเหตุ · ถ้าต้องการละเอียดขึ้นเพิ่ม on TypeError
    throw const ApiException('เชื่อมต่ออินเทอร์เน็ตไม่ได้ โปรดตรวจสอบการเชื่อมต่อ');
  }
}
