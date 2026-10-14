import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';

// ============================================================================
// แลป 12.8: หน้าจอที่ใช้ TodoProvider (ข้อมูลเครือข่าย + Provider)
// ============================================================================
class TodoProviderScreen extends StatefulWidget {
  const TodoProviderScreen({super.key});

  @override
  State<TodoProviderScreen> createState() => _TodoProviderScreenState();
}

class _TodoProviderScreenState extends State<TodoProviderScreen> {
  @override
  void initState() {
    super.initState();
    // [ข้อสอบ] หลุมพรางยอดนิยม: เขียน context.read<TodoProvider>().loadTodos() ใน initState ตรง ๆ
    //          → error "setState() or markNeedsBuild() called during build"
    //          เพราะ loadTodos() เรียก notifyListeners() ทันที ขณะ initState ยังอยู่ในเฟส
    //          สร้างวิดเจ็ตของเฟรมแรก — เฟรมเวิร์กไม่อนุญาตให้สั่งผู้ฟัง rebuild ในจังหวะนั้น
    // [วิธีแก้] addPostFrameCallback: เลื่อนไปเรียกหลังเฟรมแรกวาดเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // เช็ก mounted: ผู้ใช้อาจกดย้อนกลับออกไปก่อนเฟรมแรกจบ
      if (!mounted) return;
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List with Provider')),
      // Consumer ตามบทที่ 11: rebuild เฉพาะส่วน body
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          // ---- สถานะ 1: กำลังโหลดครั้งแรก (ยังไม่มีข้อมูลอะไรเลย) ----
          // [ข้อสอบ] บอกด้วย isLoading — ไม่ใช่ "ลิสต์ว่าง" เพราะลิสต์ว่างมีความหมายว่า
          //          "ดึงสำเร็จแต่ไม่มีรายการ" ถ้าใช้แทนกัน ผู้ใช้จะเข้าใจผิด
          if (provider.isLoading && provider.todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---- สถานะ 2: ผิดพลาดและไม่มีข้อมูลเก่าค้าง ----
          // [ข้อสอบ] provider เป็นผู้จำ error (ไม่ใช่หน้าจอ) เพราะ error เป็นสถานะของ "ข้อมูลชุดนั้น"
          //          สลับไปหน้าอื่นแล้วกลับมา สถานะยังอยู่ครบ ไม่ยิงคำขอซ้ำโดยไม่จำเป็น
          if (provider.errorMessage != null && provider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<TodoProvider>().loadTodos(),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          // ---- สถานะ 3: มีข้อมูล (รวมกรณีโหลดซ้ำทับข้อมูลเดิม → คงรายการเดิมไว้) ----
          return Column(
            children: [
              if (provider.isLoading) const LinearProgressIndicator(),
              if (provider.errorMessage != null)
                MaterialBanner(
                  content: Text('${provider.errorMessage} (แสดงข้อมูลรอบก่อน)'),
                  actions: [
                    TextButton(
                      onPressed: () => context.read<TodoProvider>().loadTodos(),
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(provider.todos[index].title));
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // [ข้อดี] สั่งโหลดซ้ำจากที่ไหนก็ได้ โดยไม่ต้องสร้างหน้าจอใหม่ (ทำยากกว่าเมื่อใช้ FutureBuilder)
        onPressed: () => context.read<TodoProvider>().loadTodos(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
