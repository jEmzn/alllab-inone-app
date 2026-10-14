import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../ch12/screens/network_mode_bar.dart';
import '../data/app_database.dart';
import '../providers/todo_provider.dart';
import '../repositories/todo_repository.dart';
import 'todo_list_screen.dart';

// ============================================================================
// แลปบทที่ 13 (13.10): todo_offline — SQLite + เครือข่าย + Provider (offline-first)
//
// สายพานข้อมูล:  หน้าจอ → TodoProvider → TodoRepository
//   TodoRepository → SQLite              (หน้าจออ่านจากตรงนี้เสมอ)
//   TodoRepository → fetchTodos() เครือข่าย  (ได้ข้อมูลมาเขียนทับ DB)
//
// ใน main.dart ของตำรา:
//   Future<void> main() async {
//     WidgetsFlutterBinding.ensureInitialized();   // ต้องมีก่อน plugin ใด ๆ ก่อน runApp
//     final db = await openAppDatabase();          // เปิดครั้งเดียวตลอดอายุแอป
//     runApp(ChangeNotifierProvider(create: (_) => TodoProvider(TodoRepository(db)), child: MyApp()));
//   }
// ที่นี่แลปรันอยู่ในแอปทบทวนอยู่แล้ว (เรียก ensureInitialized ให้แล้ว) จึงเปิด DB
// ใน initState ของวิดเจ็ตนี้แทน แล้วค่อยสร้าง provider เมื่อ DB พร้อม
//
// ทดลอง 4 สถานะ (ใช้แถบโหมดเครือข่ายด้านบนแทนโหมดเครื่องบิน):
//   1) "จำลอง: สำเร็จ" → วงล้อ → รายการ 200 รายการ
//   2) เปลี่ยนเป็น "ไม่มีสัญญาณ" แล้วออกจากแลป เข้าใหม่ → เห็นรายการเดิมทันที + แถบข้อความ
//   3) เปลี่ยนกลับเป็น "สำเร็จ" แล้วกด "ลองใหม่" → แถบบาง ๆ ใต้ AppBar ขณะรายการเดิมอยู่
//   4) ล้างข้อมูลแอปบนเครื่อง (Clear storage) → ไม่มีสัญญาณ → error เต็มหน้า + ปุ่มลองใหม่
// ============================================================================
class Ch13TodoOfflineApp extends StatefulWidget {
  const Ch13TodoOfflineApp({super.key});

  @override
  State<Ch13TodoOfflineApp> createState() => _Ch13TodoOfflineAppState();
}

class _Ch13TodoOfflineAppState extends State<Ch13TodoOfflineApp> {
  // [คืออะไร] เก็บ Future ของการเปิดฐานข้อมูลไว้ใน State (สร้างครั้งเดียวใน initState)
  // [ทำไม]   openAppDatabase() เป็น async — ต้องรอเสร็จก่อนสร้าง Repository/Provider
  //          ถ้าเรียกใน build จะเปิดซ้ำทุกครั้งที่ rebuild (บท 12: ห้ามเริ่มงาน async ใน build)
  // [จำเป็น?] เฉพาะแลปนี้ (ในตำราแก้ด้วย main() แบบ async) — แอปจริงทำใน main() ได้เลย
  late final Future<Database> _dbFuture;

  @override
  void initState() {
    super.initState();
    _dbFuture = openAppDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkModeBar(
      child: FutureBuilder<Database>(
        future: _dbFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('เปิดฐานข้อมูลไม่ได้: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ChangeNotifierProvider(
            create: (_) => TodoProvider(TodoRepository(snapshot.data!)),
            child: const MaterialApp(
              title: 'Offline-first Todos',
              debugShowCheckedModeBanner: false,
              home: TodoListScreen(),
            ),
          );
        },
      ),
    );
  }
}
