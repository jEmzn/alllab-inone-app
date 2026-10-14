// ============================================================================
// Item (provider_shop) — เพิ่ม price จากแลปที่ 1
//
// [ข้อสอบ] ต่างจากแลป provider_editor_lab: ไม่แก้ฟิลด์ของ Item ตรง ๆ อีกต่อไป
//          ตอนแก้ไขจะ "สร้าง Item ใหม่" แล้วแทนที่ในลิสต์ (ItemProvider.updateItem)
//          [ข้อดี] เปลี่ยน instance ⇒ Selector เทียบด้วย == (identity) แล้วรู้ว่าแถวไหนเปลี่ยน
//          [ข้อเสีย] สร้างอ็อบเจกต์ใหม่ทุกครั้ง (ไม่แพงสำหรับข้อมูลระดับนี้)
// ============================================================================
class Item {
  final String id;
  String name;
  String description;
  double price;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}
