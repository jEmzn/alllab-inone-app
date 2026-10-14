import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';

// ============================================================================
// EditItemScreen — หน้าแก้ไข: ส่ง "คำสั่ง" ไปที่ provider แล้วปิดหน้า (ขั้นตอนที่ 4)
//
// บทบาทตามแผนภาพ swimlane ของบท:
//   หน้านี้ = "ลูกค้า" เขียนออเดอร์แล้วส่งให้ (context.read) ไม่ต้องรอดูผล (fire and forget)
//   ItemProvider = "พ่อครัว" ทำเสร็จแล้วสั่นกระดิ่ง (notifyListeners)
//   Consumer ในหน้ารายการ = "พนักงานเสิร์ฟ" ได้ยินกระดิ่งแล้วอัปเดตหน้าจอ
// ============================================================================
class EditItemScreen extends StatefulWidget {
  static const String routeName = '/edit-item';
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // [คืออะไร] controller ของสองช่อง · `late final` เพราะกำหนดค่าครั้งเดียวทีหลัง
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late Item _item;

  // [คืออะไร] "ยาม" กันไม่ให้ didChangeDependencies กำหนดค่าซ้ำ
  // [ทำไม]   didChangeDependencies ถูกเรียกได้หลายครั้ง (ธีมเปลี่ยน/หมุนจอ/เปลี่ยนภาษา)
  //          ถ้าไม่มียาม: `late final` ถูกกำหนดซ้ำ → LateInitializationError
  //          และ controller ตัวเก่าค้างในหน่วยความจำโดยไม่ถูก dispose
  // [จำเป็น?] จำเป็น — เวอร์ชันแรกในตำรา (ไม่มียาม) มีบั๊กนี้ ตำราแก้ด้วยโค้ดนี้
  bool _isInit = false;

  // [ข้อสอบ] ทำไมไม่ใช้ initState? ModalRoute.of(context) ต้องใช้ context ที่ผูกกับ tree
  //          สมบูรณ์แล้ว ซึ่งยังไม่พร้อมใน initState → ใช้ didChangeDependencies
  //          (ลำดับ: initState → didChangeDependencies → build)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) return; // ครั้งที่สองเป็นต้นไปไม่ต้องทำอะไร
    _isInit = true;

    // ดึง Item ที่ถูกส่งมาจากหน้ารายการ
    _item = ModalRoute.of(context)!.settings.arguments as Item;

    // [คืออะไร] TextEditingController(text: ...) = กำหนดข้อความเริ่มต้นของช่อง
    _nameController = TextEditingController(text: _item.name);
    _descriptionController = TextEditingController(text: _item.description);
  }

  @override
  void dispose() {
    // [จำเป็น?] จำเป็น — คืนทรัพยากร controller (บทที่ 7-8)
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // [ข้อสอบ] ใช้ context.read (ไม่ใช่ watch) เพราะอยู่ใน event handler และ
    //          หน้านี้ไม่ต้อง rebuild ตามการเปลี่ยนแปลงของ provider
    context.read<ItemProvider>().updateItem(
          _item.id,
          _nameController.text,
          _descriptionController.text,
        );
    // กลับหน้ารายการ — Consumer ฝั่งนั้นจะได้รับแจ้งเอง ไม่ต้องส่งผลลัพธ์กลับผ่าน pop
    // [ข้อดี] เทียบกับบทที่ 9 (ส่งผลลัพธ์กลับด้วย pop แล้ว setState): ที่นี่ผู้เรียกไม่ต้องรอ/จัดการอะไร
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไข: ${_item.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'คำอธิบาย'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('บันทึกการเปลี่ยนแปลง'),
            ),
          ],
        ),
      ),
    );
  }
}
