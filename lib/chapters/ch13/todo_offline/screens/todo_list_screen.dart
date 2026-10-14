import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';

// ============================================================================
// TodoListScreen (offline-first) — หน้าจอเลือกแสดงผลตาม "4 สถานะ" (13.10.1 ขั้นตอนที่ 6)
//
//  สถานะที่ 1  ไม่มีข้อมูลในเครื่อง + กำลังรีเฟรช
//              → วงล้อหมุนเต็มหน้า (เปิดแอปครั้งแรก)
//  สถานะที่ 2  ไม่มีข้อมูลในเครื่อง + รีเฟรชไม่สำเร็จ
//              → ข้อความ error + ปุ่ม "ลองใหม่" เต็มหน้า
//  สถานะที่ 3  มีข้อมูล + กำลังรีเฟรช
//              → รายการเดิม + แถบบาง ๆ ใต้ AppBar (ห้ามเปลี่ยนทั้งหน้าเป็นวงล้อ)
//  สถานะที่ 4  มีข้อมูล + รีเฟรชไม่สำเร็จ
//              → รายการเดิม + MaterialBanner บอกที่มาของข้อมูล + ปุ่มลองใหม่
// ============================================================================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    // [ข้อสอบ] load() เรียก notifyListeners() ทันที จึงต้องเลื่อนไปหลังเฟรมแรก (12.8)
    //          ไม่งั้นชน "setState() or markNeedsBuild() called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TodoProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // [ทำไม]   ใช้ watch ที่ระดับ build เพราะแทบทุกส่วนของหน้านี้ขึ้นกับ provider
    //          (บท 11: จะตีกรอบด้วย Consumer/select ก็ได้ แต่หน้านี้เล็ก ไม่คุ้มความซับซ้อน)
    final provider = context.watch<TodoProvider>();
    final hasData = provider.todos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos (offline-first)'),
        // สถานะ "มีข้อมูลและกำลังรีเฟรช": แถบบาง ๆ ใต้ AppBar
        bottom: hasData && provider.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: _buildBody(provider, hasData),
    );
  }

  Widget _buildBody(TodoProvider provider, bool hasData) {
    // ไม่มีข้อมูลและกำลังรีเฟรช: เปิดแอปครั้งแรก
    if (!hasData && provider.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }
    // ไม่มีข้อมูลและรีเฟรชไม่สำเร็จ: ข้อความผิดพลาดพร้อมปุ่มลองใหม่เต็มหน้า
    if (!hasData && provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: provider.load, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }
    // มีข้อมูล: แสดงรายการเดิมเสมอ ถ้ารีเฟรชไม่สำเร็จให้มีแถบบอกที่มาของข้อมูล
    return Column(
      children: [
        if (provider.errorMessage != null)
          MaterialBanner(
            content: Text(
              'แสดงข้อมูล${_syncedText(provider.lastSynced)}\n'
              '${provider.errorMessage}',
            ),
            actions: [
              TextButton(onPressed: provider.load, child: const Text('ลองใหม่')),
            ],
          ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return CheckboxListTile(
                value: todo.completed,
                onChanged: null, // แสดงอย่างเดียว ไม่ให้แก้ไข
                title: Text(todo.title),
              );
            },
          ),
        ),
      ],
    );
  }

  // lastSynced เป็น null เมื่อเปิดแอปใหม่แล้วยังซิงก์ไม่สำเร็จเลย
  String _syncedText(DateTime? synced) {
    if (synced == null) return 'ที่บันทึกไว้ในเครื่องจากครั้งก่อน';
    return 'เมื่อ ${TimeOfDay.fromDateTime(synced).format(context)}';
  }
}
