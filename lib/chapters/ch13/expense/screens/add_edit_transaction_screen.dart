import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

// ============================================================================
// AddEditTransactionScreen — "การบ้านของบทที่ 13" (ฉบับเฉลย)
//
// โจทย์ในตำรา: สร้างฟอร์มเพิ่ม/แก้ไข โดยใช้ความรู้บท 8 และ 9 แล้วเรียก
//   addTransaction / updateTransaction ของ Provider
// ไฟล์นี้รวมความรู้:  บท 7 (State, initState/dispose) · บท 8 (Form, validator, controller)
//                     · บท 9 (ส่งข้อมูลผ่าน constructor, pop) · บท 10 (context.read)
//                     · บท 12 (await + mounted) · บท 13 (CRUD ผ่าน provider)
//
// หนึ่งฟอร์มใช้ได้ทั้ง "เพิ่ม" และ "แก้ไข" — แยกด้วยว่า transaction เป็น null หรือไม่
// ============================================================================
class AddEditTransactionScreen extends StatefulWidget {
  // [คืออะไร] null = โหมดเพิ่ม · มีค่า = โหมดแก้ไข (ส่งผ่าน constructor — บทที่ 9)
  final MyTransaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  // state ของฟิลด์ที่ไม่ใช่ข้อความ (ต้อง setState เมื่อเปลี่ยน)
  late DateTime _date;
  late TransactionType _type;

  // [คืออะไร] getter สะดวกอ่าน: กำลังแก้ไขอยู่หรือไม่
  bool get _isEditing => widget.transaction != null;

  // [ข้อสอบ] ตั้งค่าเริ่มต้นจาก widget.transaction ใน initState (อ่านค่าจาก constructor ได้ที่นี่
  //          — ต่างจาก ModalRoute ที่ต้องรอ didChangeDependencies)
  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(text: tx == null ? '' : tx.amount.toString());
    _date = tx?.date ?? DateTime.now();
    _type = tx?.type ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // [คืออะไร] showDatePicker : dialog เลือกวันที่ของ Material คืน Future<DateTime?>
  //          (null เมื่อผู้ใช้กดยกเลิก)
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // [ข้อสอบ] หลัง await ต้องเช็ก mounted ก่อน setState (บทที่ 12)
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    // validate → ถ้าไม่ผ่านหยุดทันที (error แสดงใต้ช่องเอง)
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    // [ทำไม]   ดึง provider "ก่อน" await (read ใน event handler) และเก็บ navigator ไว้ใช้หลัง await
    //          — ไม่ถือ context ข้าม await (บทที่ 12)
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);

    if (_isEditing) {
      // [ข้อสอบ] แก้ไข: สร้าง MyTransaction ใหม่ที่ "ไม่ใส่ id" ก็ได้ เพราะ updateTransaction
      //          รับ id แยก และ toMap ไม่ส่ง id ที่เป็น null (ถ้าใส่ id เดิมก็ใช้ได้เช่นกัน)
      await provider.updateTransaction(
        widget.transaction!.id!,
        MyTransaction(title: title, amount: amount, date: _date, type: _type),
      );
    } else {
      await provider.addTransaction(title, amount, _date, _type);
    }

    // เก็บ navigator ไว้ก่อน await จึงปลอดภัยแม้หน้านี้ถูกปิดไปแล้ว
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'รายการ',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'กรุณาป้อนชื่อรายการ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงิน (บาท)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                // [ข้อสอบ] tryParse คืน null เมื่อแปลงไม่ได้ (ไม่ throw เหมือน parse)
                //          validator ต้องกันค่าที่ทำให้ double.parse ใน _submit พัง
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null) return 'กรุณาป้อนตัวเลขที่ถูกต้อง';
                  if (amount <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // เลือกประเภท: SegmentedButton (Material 3)
              // [ทางเลือก] RadioGroup (บท 8.9) หรือ DropdownButtonFormField — ทำงานเหมือนกัน
              // [ข้อสอบ] วิดเจ็ตเหล่านี้ "ไม่ใช่ FormField" validate()/save() ของ Form มองไม่เห็น
              //          จึงเก็บค่าไว้ใน state (_type) แล้วอ่านตอน _submit เอง
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income, label: Text('รายรับ')),
                  ButtonSegment(value: TransactionType.expense, label: Text('รายจ่าย')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat.yMMMd().format(_date)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
