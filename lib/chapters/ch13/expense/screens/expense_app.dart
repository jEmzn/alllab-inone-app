import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import 'transaction_list_screen.dart';

// ============================================================================
// แลปบทที่ 13 (ปฏิบัติการหลัก): expense_tracker_provider  (ไฟล์นี้ = main.dart)
//
// ไฟล์ในแลปนี้ (ตามลำดับที่ควรอ่าน):
//   models/my_transaction.dart                    ← กระบวนการ 2: Model + toMap/fromMap
//   providers/transaction_provider.dart           ← กระบวนการ 2-6: เปิด DB + CRUD (หัวใจ)
//   screens/transaction_list_screen.dart          ← กระบวนการ 4, 6: Consumer + ลบ
//   screens/add_edit_transaction_screen.dart      ← การบ้าน: ฟอร์มเพิ่ม/แก้ไข (เฉลย)
//   screens/expense_app.dart                      ← (ไฟล์นี้) ประกอบทุกอย่าง
//
// pubspec.yaml: sqflite · path · provider · intl
// ============================================================================
class Ch13ExpenseApp extends StatelessWidget {
  const Ch13ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] ของจริง: runApp(ChangeNotifierProvider(create: (_) => TransactionProvider(),
    //          child: MyApp())) — ที่นี่ย้ายมาห่อ MaterialApp (ผลเท่ากัน)
    // [ทำไม]   create ทำงาน (lazy) ตอนมีวิดเจ็ตขอใช้ครั้งแรก → constructor ของ provider
    //          เรียก fetchAndSetTransactions() → เปิด DB อัตโนมัติ
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: const MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        home: TransactionListScreen(),
      ),
    );
  }
}
