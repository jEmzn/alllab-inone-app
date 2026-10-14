import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/note.dart';

// ============================================================================
// NotesScreen — UI ทดสอบ CRUD ของ DatabaseHelper (หัวข้อ 13.6 – 13.9)
//
// สถาปัตยกรรมของแลปนี้ = "Helper แบบ Singleton + setState ในหน้าจอ"
//   หน้าจอเรียก DatabaseHelper.instance ตรง ๆ แล้ว setState เอง
// เทียบกับแลป expense_tracker: "Provider ถือฐานข้อมูล แล้ว notifyListeners"
// (หัวข้อ 13.12 ชวนคิด: เมื่อมี provider หลายตัวใช้ DB ไฟล์เดียว แบบไหนดีกว่า?)
// ============================================================================
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // [คืออะไร] เก็บ reference ของ Singleton ไว้ใช้สั้น ๆ
  final dbHelper = DatabaseHelper.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Note> _notes = [];

  // [คืออะไร] ถ้าไม่ null = กำลังแก้ไขโน้ตนี้อยู่ (ปุ่มเปลี่ยนเป็น "บันทึกการแก้ไข")
  Note? _editing;

  @override
  void initState() {
    super.initState();
    _refreshNotes(); // โหลดข้อมูลครั้งแรกตอนเปิดหน้า
  }

  @override
  void dispose() {
    // [บทที่ 8] คืนหน่วยความจำของ controller เมื่อหน้าจอถูกทำลาย
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // [คืออะไร] อ่านจาก DB แล้ว setState — รูปแบบ "เขียนแล้วอ่านใหม่" หลังทุกการเปลี่ยนแปลง
  // [ทำไม]   ให้ UI สะท้อน "ข้อมูลจริงในฐานข้อมูล" (single source of truth) ไม่ใช่สำเนาในหน้า
  // [ข้อสอบ] ต้องเช็ก mounted หลัง await ก่อน setState (บทที่ 12): ผู้ใช้อาจออกจากหน้าไปแล้ว
  Future<void> _refreshNotes() async {
    final data = await dbHelper.queryAllNotes();
    if (!mounted) return;
    setState(() {
      _notes = data;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return; // ตารางกำหนด NOT NULL — กันข้อมูลว่างก่อนถึง DB

    if (_editing == null) {
      // INSERT: ไม่ส่ง id → ฐานข้อมูลสร้างให้ (AUTOINCREMENT)
      final id = await dbHelper.insertNote(
        Note(title: title, content: content, createdAt: DateTime.now()),
      );
      debugPrint('Inserted row id: $id');
    } else {
      // UPDATE: ต้องส่ง id ของแถวเดิม (toMap ใส่ id เมื่อมีค่า) และรักษา createdAt เดิม
      final rows = await dbHelper.updateNote(
        Note(
          id: _editing!.id,
          title: title,
          content: content,
          createdAt: _editing!.createdAt,
        ),
      );
      debugPrint('Updated $rows row(s)');
    }
    _clearForm();
    await _refreshNotes();
  }

  void _startEdit(Note note) {
    setState(() => _editing = note);
    _titleController.text = note.title;
    _contentController.text = note.content;
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() => _editing = null);
  }

  Future<void> _delete(int id) async {
    final rows = await dbHelper.deleteNote(id);
    debugPrint('Deleted $rows row(s): row $id');
    await _refreshNotes();
  }

  // ตัวอย่าง transaction + batch (13.9): แทนที่โน้ตทั้งหมดด้วยชุดตัวอย่าง 100 รายการ
  Future<void> _replaceWithSamples() async {
    final sw = Stopwatch()..start();
    await dbHelper.replaceAllNotes([
      for (var i = 1; i <= 100; i++)
        Note(title: 'ตัวอย่าง $i', content: 'สร้างด้วย batch ใน transaction', createdAt: DateTime.now()),
    ]);
    debugPrint('replaceAllNotes 100 แถว ใช้เวลา ${sw.elapsedMilliseconds} ms');
    await _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite C.R.U.D. Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_editing == null ? 'Insert Note' : 'Update Note'),
                ),
                if (_editing != null)
                  TextButton(onPressed: _clearForm, child: const Text('ยกเลิก')),
                const Spacer(),
                TextButton(
                  onPressed: _replaceWithSamples,
                  child: const Text('แทนที่ด้วย 100 ตัวอย่าง'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(note.title),
                      // created_at เป็น null สำหรับโน้ตที่สร้างก่อน upgrade เป็น version 2
                      subtitle: Text(
                        '${note.content}\n'
                        '${note.createdAt == null ? "(ไม่มีวันที่ — สร้างก่อน v2)" : note.createdAt!.toString().split(".").first}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _startEdit(note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _delete(note.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
