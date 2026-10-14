import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/api_service.dart';

// ============================================================================
// แลป 12.5-12.7: รายการ Todo จาก API ด้วย FutureBuilder (ฉบับรับมือความล้มเหลว)
//
// ไหลของข้อมูล:  API → fetchTodos() [http+timeout+compute+แปลง error]
//               → Future<List<Todo>> → FutureBuilder → ListView
//
// รวม 3 เรื่องที่ตำราชี้ว่าบทเรียนส่วนใหญ่ข้าม:
//   1. ลำดับตรวจ snapshot ที่ "ไม่กระพริบ" ตอนรีเฟรช
//   2. ปุ่ม "ลองใหม่" ที่ขึ้นตามเงื่อนไข canRetry
//   3. ลากลงเพื่อรีเฟรชด้วย RefreshIndicator
// ============================================================================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> _futureTodos;

  @override
  void initState() {
    super.initState();
    _futureTodos = fetchTodos(); // เริ่มงานใน initState เก็บ Future ไว้ (ไม่ใช่ใน build)
  }

  // [คืออะไร] สั่งโหลดใหม่ = สร้าง Future ตัวใหม่ แล้ว setState ให้ FutureBuilder ฟังตัวใหม่
  Future<void> _reload() async {
    final future = fetchTodos();
    // [ข้อสอบ] ต้องใช้ block body { ... } ห้ามเขียน setState(() => _futureTodos = future)
    //          เพราะ arrow function "คืนค่าของ assignment" ซึ่งคือ Future →
    //          setState ตรวจเจอว่า callback คืน Future แล้ว assert พัง (ใน debug)
    //          (callback ของ setState ต้องเป็น void/ซิงโครนัส · ตำราต้นฉบับเขียนแบบ arrow
    //          ซึ่งใช้งานจริงไม่ได้ — แก้ไว้ที่นี่แล้ว)
    setState(() {
      _futureTodos = future;
    });
    try {
      // [ทำไม]   RefreshIndicator ต้องรู้ว่า "งานจบแล้ว" จึงหยุดหมุน → ต้อง await
      await future;
    } catch (_) {
      // ไม่ต้องทำอะไร: FutureBuilder จะแสดงข้อผิดพลาดให้เอง
      // [ข้อสอบ] ต้อง catch ที่นี่ ไม่งั้น exception หลุดออกมาจาก onRefresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List from API')),
      // [คืออะไร] RefreshIndicator = ลากลงเพื่อรีเฟรช (ท่ามาตรฐานบนมือถือ)
      //          onRefresh ต้องคืน Future
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Todo>>(
          future: _futureTodos,
          builder: (context, snapshot) {
            // ---- 1. ตรวจ "ข้อผิดพลาด" ก่อน ----
            if (snapshot.hasError) {
              final error = snapshot.error;
              // ถ้าเป็น ApiException ใช้ข้อความภาษาคนของมันได้เลย
              final message =
                  error is ApiException ? error.message : 'เกิดข้อผิดพลาดที่ไม่คาดคิด';
              final canRetry = error is! ApiException || error.canRetry;
              // [ข้อสอบ] ต้องเป็นวิดเจ็ตที่ "เลื่อนได้" (ListView) ไม่งั้นลากลงเพื่อรีเฟรชไม่ได้
              return ListView(
                padding: const EdgeInsets.only(top: 120),
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  // ปุ่ม "ลองใหม่" แสดงเฉพาะเมื่อลองใหม่มีประโยชน์ (4xx ไม่แสดง)
                  if (canRetry)
                    Center(
                      child: ElevatedButton(onPressed: _reload, child: const Text('ลองใหม่')),
                    ),
                ],
              );
            }

            // ---- 2. ยัง "ไม่มีข้อมูลเลย" จึงแสดงวงล้อ ----
            // [ข้อสอบ] ใช้ !hasData ไม่ใช่ connectionState == waiting:
            //          ตอนรีเฟรช hasData ยัง true (ข้อมูลเก่าค้าง) → ข้ามเงื่อนไขนี้
            //          รายการเดิมจึงไม่หายไป/ไม่กระพริบ
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // ---- 3. มีข้อมูล ----
            final todos = snapshot.data!;
            // [คืออะไร] ListView.builder สร้างเฉพาะแถวที่มองเห็น (ประหยัดเมื่อมี 200 รายการ)
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(child: Text(todos[index].id.toString())),
                title: Text(todos[index].title),
                trailing: Icon(
                  todos[index].completed ? Icons.check_box : Icons.check_box_outline_blank,
                  color: todos[index].completed ? Colors.green : Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
