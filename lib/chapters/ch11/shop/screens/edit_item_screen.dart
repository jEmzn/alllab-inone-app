import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';

// ============================================================================
// EditItemScreen (provider_shop) — ฟอร์มแก้ไขสินค้า (รวมบท 8 + 9 + 10 เข้าด้วยกัน)
//   บท 8: Form, GlobalKey<FormState>, validator, onSaved, TextEditingController
//   บท 9: รับ arguments ผ่าน named route (ModalRoute)
//   บท 10: context.read เรียก provider
// ============================================================================
class EditItemScreen extends StatefulWidget {
  static const routeName = '/edit-item';
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _itemId;
  late Item _editedItem;
  bool _isInit = false;

  // [คืออะไร] ประกาศพร้อมสร้าง controller ตรงนี้เลย (ต่างจากแลปที่ 1 ที่ `late final`)
  // [ข้อดี]   ไม่ต้องกังวลเรื่อง late · [ข้อเสีย] สร้างทันทีที่ State ถูกสร้าง
  //          แต่ค่า text ต้องตั้งทีหลังใน didChangeDependencies เพราะต้องรอข้อมูลจาก route
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _itemId = ModalRoute.of(context)!.settings.arguments as String;

      // [คืออะไร] Provider.of<T>(context, listen: false) ≡ context.read<T>()
      // [ทำไม]   ที่นี่ไม่ต้องการ rebuild เมื่อ provider เปลี่ยน (แค่หยิบค่าตั้งต้นครั้งเดียว)
      // [ข้อสอบ] listen: false คือรูปแบบเก่าของ read — ต้องรู้ว่าเป็นสิ่งเดียวกัน
      _editedItem = Provider.of<ItemProvider>(context, listen: false).findById(_itemId);

      _nameController.text = _editedItem.name;
      _descController.text = _editedItem.description;
      _priceController.text = _editedItem.price.toString();
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // validate → ถ้าไม่ผ่านหยุด (error แสดงใต้ช่องเอง)
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    // save → onSaved ของแต่ละช่องรันตามลำดับ ประกอบ _editedItem ทีละฟิลด์
    _formKey.currentState!.save();

    context.read<ItemProvider>().updateItem(_itemId, _editedItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขรายละเอียดสินค้า'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // [คืออะไร] ListView แทน Column: เลื่อนได้เมื่อคีย์บอร์ดบังพื้นที่ (บทที่ 8 แบบฝึกหัด 5)
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาป้อนชื่อสินค้า';
                  return null;
                },
                // [ข้อเสีย] onSaved แบบนี้สร้าง Item ใหม่ทีละฟิลด์ 3 รอบ (อ่านยาก)
                //          [ทางเลือก] อ่านจาก controller.text ตอนเรียก updateItem ครั้งเดียว
                //          (เหมือนแลปที่ 1) — สั้นกว่า แต่ onSaved ทำให้ขั้นตอน validate→save ชัดเจน
                onSaved: (value) {
                  _editedItem = Item(
                    id: _editedItem.id,
                    name: value!,
                    description: _editedItem.description,
                    price: _editedItem.price,
                  );
                },
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาป้อนรายละเอียด';
                  return null;
                },
                onSaved: (value) {
                  _editedItem = Item(
                    id: _editedItem.id,
                    name: _editedItem.name,
                    description: value!,
                    price: _editedItem.price,
                  );
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'ราคา'),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                // [ข้อสอบ] validator ซ้อนหลายเงื่อนไข: ว่าง → ไม่ใช่ตัวเลข → ไม่เป็นบวก
                //          tryParse คืน null เมื่อแปลงไม่ได้ (ไม่ throw เหมือน parse)
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาป้อนราคา';
                  if (double.tryParse(value) == null) return 'กรุณาป้อนตัวเลขที่ถูกต้อง';
                  if (double.parse(value) <= 0) return 'ราคาต้องมากกว่า 0';
                  return null;
                },
                onSaved: (value) {
                  _editedItem = Item(
                    id: _editedItem.id,
                    name: _editedItem.name,
                    description: _editedItem.description,
                    price: double.parse(value!),
                  );
                },
                onFieldSubmitted: (_) => _saveForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
