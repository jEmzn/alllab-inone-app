// ============================================================================
// Item — Data Model ของแลป provider_editor_lab (ขั้นตอนที่ 2)
//
// [คืออะไร] คลาสธรรมดา (ไม่เกี่ยวกับ Flutter) ที่แทน "สินค้าหนึ่งชิ้น"
// [ทำไม]   ใช้คลาสแทน Map<String, String> เพื่อให้คอมไพเลอร์ตรวจชื่อฟิลด์/ชนิดให้
// [จำเป็น?] ไม่จำเป็นต่อ Provider แต่เป็นแนวปฏิบัติที่ดีเสมอ
// ============================================================================
class Item {
  // [คืออะไร] id เป็น final (ไม่เปลี่ยน) เพราะเป็นตัวระบุตัวตนของสินค้า
  final String id;

  // [ข้อเสีย] name/description เป็น "mutable" (แก้ได้ตรง ๆ) — สะดวกในแลปนี้
  //          แต่เสี่ยง: ใครถือ reference ของ Item ก็แก้ได้โดยไม่ผ่าน provider
  //          → จะไม่มี notifyListeners() แล้ว UI ไม่อัปเดต
  //          (แลป 2 provider_shop แก้เป็นการสร้าง Item ใหม่ทับของเดิมแทน)
  String name;
  String description;

  Item({required this.id, required this.name, required this.description});
}
