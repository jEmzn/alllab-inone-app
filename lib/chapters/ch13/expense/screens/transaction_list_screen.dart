import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_screen.dart';

// ============================================================================
// TransactionListScreen — หน้าหลัก (กระบวนการที่ 4 + 6)
//
// [คืออะไร] StatelessWidget — หน้านี้ไม่มี state ของตัวเอง ข้อมูลทั้งหมดอยู่ใน provider
// [ข้อสอบ] หน้าจอไม่มี SQL และไม่รู้จัก sqflite เลย (Separation of Concerns)
// ============================================================================
class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),

      // [คืออะไร] Consumer ฟัง TransactionProvider · builder ทำงานใหม่ทุกครั้งที่ notifyListeners
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          final items = txProvider.transactions;
          if (items.isEmpty) {
            // [ข้อสอบ] ลิสต์ว่าง = "ยังไม่มีรายการ" (หรือกำลังโหลดครั้งแรก) ที่นี่จึงไม่แยก isLoading
            //          ถ้าต้องแยก ให้เพิ่ม isLoading ใน provider (ตามบทที่ 12)
            return const Center(child: Text('ไม่มีรายการ'));
          }
          return Column(
            children: [
              // ยอดคงเหลือ: ค่าจาก provider (คำนวณด้วย SUM ใน SQLite)
              Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: const Text('ยอดคงเหลือ'),
                  trailing: Text(
                    '${txProvider.balance.toStringAsFixed(2)} บาท',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: txProvider.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final tx = items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(tx.type == TransactionType.income ? 'รับ' : 'จ่าย'),
                      ),
                      title: Text(tx.title),
                      // [คืออะไร] intl: DateFormat.yMMMd() จัดรูปแบบวันที่ (เช่น Oct 10, 2026)
                      subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                      // แตะเพื่อแก้ไข: ส่งอ็อบเจกต์ผ่าน constructor (บทที่ 9 — วิธีที่ควรเลือกก่อน)
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTransactionScreen(transaction: tx),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${tx.amount.toStringAsFixed(2)} บาท',
                            style: TextStyle(
                              color: tx.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            // [ข้อสอบ] ใน callback ใช้ context.read (ไม่ใช่ watch)
                            // tx.id! : id เป็น int? แต่ข้อมูลที่อ่านจาก DB มี id เสมอ
                            onPressed: () {
                              context.read<TransactionProvider>().deleteTransaction(tx.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ปุ่มเพิ่ม → เปิดฟอร์มโหมด "เพิ่ม" (ไม่ส่ง transaction)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
