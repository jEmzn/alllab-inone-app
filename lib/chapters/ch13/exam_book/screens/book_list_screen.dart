import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import 'book_form_screen.dart';

// ============================================================================
// BookListScreen — ขั้น 6 ของสูตร: หน้ารายการ
//   Consumer + ListView.builder + (ลบ) + (ไปหน้าแก้ไข) + (เพิ่ม) + ค้นหา + ติ๊กอ่านแล้ว
// ============================================================================
class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หนังสือของฉัน')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ค้นหาชื่อหนังสือ',
                border: OutlineInputBorder(),
              ),
              // [ข้อสอบ] callback → context.read · ค้นหาใน SQL (LIKE ?) ทุกครั้งที่พิมพ์
              onChanged: (value) => context.read<BookProvider>().search(value),
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, child) {
                // สถานะ: กำลังโหลดครั้งแรก ≠ ไม่มีข้อมูล (บทที่ 12)
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.books.isEmpty) {
                  return Center(
                    child: Text(provider.query.isEmpty ? 'ยังไม่มีหนังสือ กด + เพื่อเพิ่ม' : 'ไม่พบหนังสือที่ค้นหา'),
                  );
                }
                return ListView.builder(
                  itemCount: provider.books.length,
                  itemBuilder: (context, index) {
                    final book = provider.books[index];
                    // [คืออะไร] Dismissible : ปัดเพื่อลบ · ต้องมี key ที่ไม่ซ้ำและคงที่ (ValueKey ของ id)
                    // [ทำไม]   key ทำให้ Flutter รู้ว่าแถวไหนคือแถวไหนเมื่อลิสต์เปลี่ยน
                    // [ทางเลือก] ปุ่มถังขยะแบบแลป expense_tracker — ผลเหมือนกัน
                    return Dismissible(
                      key: ValueKey(book.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => context.read<BookProvider>().deleteBook(book.id!),
                      child: ListTile(
                        leading: Checkbox(
                          value: book.isRead,
                          onChanged: (_) => context.read<BookProvider>().toggleRead(book),
                        ),
                        title: Text(
                          book.title,
                          style: TextStyle(
                            decoration: book.isRead ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          '${book.author} · ${book.genre.name} · '
                          '${DateFormat.yMMMd().format(book.addedAt)}',
                        ),
                        trailing: Text('${book.price.toStringAsFixed(0)} ฿'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
