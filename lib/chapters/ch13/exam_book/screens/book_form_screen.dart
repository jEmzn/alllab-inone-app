import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';

// ============================================================================
// BookFormScreen — ขั้น 7 ของสูตร: ฟอร์มเพิ่ม/แก้ไข (ใช้ฟอร์มเดียวสองโหมด)
//
// ช่องกรอกแบ่งเป็น 2 ชนิด — เรื่องสำคัญที่ข้อสอบชอบถาม (บท 8.9):
//   FormField  (TextFormField, DropdownButtonFormField) → validate()/save() ของ Form เห็น
//   ไม่ใช่ FormField (Switch, Checkbox, Radio, Slider)   → Form มองไม่เห็น
//                                                          เก็บใน state เอง แล้วอ่านตอนส่ง
// ============================================================================
class BookFormScreen extends StatefulWidget {
  final Book? book; // null = เพิ่ม · มีค่า = แก้ไข
  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _priceController;

  // state ของช่องที่ไม่ใช่ข้อความ
  late Genre _genre;
  late bool _isRead;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _priceController = TextEditingController(text: b == null ? '' : b.price.toString());
    _genre = b?.genre ?? Genre.novel;
    _isRead = b?.isRead ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ดึง provider/navigator ก่อน await · ไม่ถือ context ข้าม await (บท 12)
    final provider = context.read<BookProvider>();
    final navigator = Navigator.of(context);

    final book = Book(
      id: widget.book?.id, // แก้ไข = ใช้ id เดิม · เพิ่ม = null
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      genre: _genre,
      isRead: _isRead,
      // แก้ไข: คงวันที่เพิ่มเดิมไว้ · เพิ่ม: ใช้เวลาปัจจุบัน
      addedAt: widget.book?.addedAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await provider.updateBook(book);
    } else {
      await provider.addBook(book);
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'แก้ไขหนังสือ' : 'เพิ่มหนังสือ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'ชื่อหนังสือ', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาป้อนชื่อหนังสือ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'ผู้แต่ง', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาป้อนชื่อผู้แต่ง' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'ราคา (บาท)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final price = double.tryParse(v?.trim() ?? '');
                  if (price == null) return 'กรุณาป้อนตัวเลข';
                  if (price < 0) return 'ราคาต้องไม่ติดลบ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // [คืออะไร] DropdownButtonFormField : dropdown ที่เป็น FormField
              // [ข้อสอบ] กำหนดค่าเริ่มต้นด้วย initialValue (พารามิเตอร์ value เดิมเลิกใช้แล้ว ตั้งแต่ Flutter 3.33)
              //          Dropdown ธรรมดา (DropdownButton) ไม่ใช่ FormField
              DropdownButtonFormField<Genre>(
                initialValue: _genre,
                decoration: const InputDecoration(labelText: 'หมวด', border: OutlineInputBorder()),
                items: [
                  for (final g in Genre.values)
                    DropdownMenuItem(value: g, child: Text(g.name)),
                ],
                onChanged: (g) => setState(() => _genre = g ?? _genre),
              ),
              const SizedBox(height: 8),

              // Switch ไม่ใช่ FormField → เก็บใน state (_isRead) · อ่านตอน _submit
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('อ่านแล้ว'),
                value: _isRead,
                onChanged: (v) => setState(() => _isRead = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มหนังสือ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
