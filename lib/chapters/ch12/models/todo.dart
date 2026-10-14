// ============================================================================
// Todo — Model class ของข้อมูลจาก API (ขั้นตอนที่ 2 ของ 12.5)
//
// ตัวอย่าง JSON ที่ได้จาก https://jsonplaceholder.typicode.com/todos :
//   { "userId": 1, "id": 1, "title": "delectus aut autem", "completed": false }
//
// [คืออะไร] คลาสที่แทน "ข้อมูลหนึ่งชิ้น" ในรูปแบบที่ Dart เข้าใจและตรวจชนิดได้
// [ทำไม]   JSON ที่ส่งมาเป็นแค่ "ข้อความ" — ถ้าใช้ Map ดิบ ๆ แล้วพิมพ์คีย์ผิด
//          (เช่น json['tilte']) คอมไพเลอร์ไม่เตือน แอปไปพังตอนรัน
//          Model + fromJson คือ "ล่าม" ที่แปลงครั้งเดียวที่ชั้นข้อมูล
// [ข้อดี]   ผิดตรงไหนรู้ตั้งแต่เขียนโค้ด · UI ใช้ todo.title แทน json['title']
// [ข้อเสีย] ต้องเขียนเองทีละฟิลด์ (โปรเจกต์ใหญ่มักใช้เครื่องมือสร้างโค้ด แต่ที่นี่ไม่ใช้แพ็กเกจเพิ่ม)
// ============================================================================
class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  // [คืออะไร] const constructor — ใช้ได้เพราะทุกฟิลด์เป็น final
  const Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  // [คืออะไร] factory constructor: สร้าง Todo จาก Map (JSON object ที่ผ่าน jsonDecode แล้ว)
  // [ทำไม]   ทำงานสองจังหวะ → (1) jsonDecode: ข้อความ → Map  (2) fromJson: Map → Todo
  // [ข้อสอบ] `as int` / `as String` / `as bool` = cast ตรวจชนิดตอนรัน
  //          ถ้า JSON ขาดฟิลด์หรือชนิดผิด จะเกิด TypeError ที่ "จุดเดียวนี้"
  //          (ชั้นบริการจับแล้วแปลงเป็นข้อความภาษาคน)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  // ---- เพิ่มในบทที่ 13 (หัวข้อ 13.10): แปลงเป็น/จากแถวของตาราง SQLite ----
  // ตารางที่คู่กัน:
  //   CREATE TABLE todos (id INTEGER PRIMARY KEY, userId INTEGER NOT NULL,
  //                       title TEXT NOT NULL, completed INTEGER NOT NULL)
  // [ทำไม]   ฟิลด์เดิมของบท 12 ไม่ต้องแก้ — เพิ่มสองเมธอดนี้เพื่อให้ repository เก็บลง SQLite ได้
  Map<String, Object?> toMap() {
    return {
      'id': id, // id มาจากเซิร์ฟเวอร์ จึงมีค่าเสมอ (ต่างจาก Note ที่ DB เป็นผู้สร้าง id)
      'userId': userId,
      'title': title,
      'completed': completed ? 1 : 0, // SQLite ไม่มี bool → เก็บ 1/0
    };
  }

  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      userId: map['userId'] as int,
      id: map['id'] as int,
      title: map['title'] as String,
      completed: map['completed'] == 1, // 1 → true, อื่น ๆ → false
    );
  }
}
