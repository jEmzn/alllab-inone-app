# แลปทบทวน Flutter บทที่ 7–13

แอปรวม "ปฏิบัติการ" ของแต่ละบท (รันได้จริง) พร้อมซอร์สโค้ดที่มีคอมเมนต์อธิบายทุกส่วน
ด้วยแท็ก `[คืออะไร] [ทำไม] [จำเป็น?] [ข้อดี] [ข้อเสีย] [ข้อสอบ]`

แต่ละแลปมี 2 ส่วน: แท็บ **รันดู** (แอปแลปที่ทำงานจริง) และแท็บไฟล์ซอร์ส (โหลดไฟล์จริงจาก asset
— โค้ดที่เห็นคือโค้ดที่กำลังรันอยู่)

| บท | แลป |
|----|-----|
| 7  | stateful_app: setState, initState/dispose, ยก state ขึ้น |
| 8  | ฟอร์มล็อกอิน: Form, validator, onSaved |
| 9  | navigate_route: push/pop, named routes, onGenerateRoute, PopScope |
| 10 | Refactor ตัวนับด้วย Provider (ก่อน/หลัง) |
| 11 | provider_editor_lab, provider_shop, แลปวัด rebuild |
| 12 | FutureBuilder, http+JSON+error handling, Provider+เครือข่าย (มีตัวจำลองเครือข่ายล้มเหลว) |
| 13 | MyNotes, todo_offline, **expense_tracker (ปฏิบัติการหลัก)**, **Exam Workshop (Book)** |

## การรัน
- `flutter run -d linux` / `-d chrome` — บท 7–12 ทำงานครบ; บท 13 แสดงข้อความว่าต้องใช้ Android/iOS (sqflite)
- `flutter run -d <android emulator>` — ทุกบททำงานครบ รวม SQLite จริง
- `flutter test` — ทดสอบพฤติกรรมของแลป (บท 13 ที่ใช้ sqflite ถูกทดสอบบน Android emulator แยกต่างหาก)

## แพ็กเกจ (เฉพาะที่ตำราสอน)
provider, http, sqflite, path, path_provider, intl
