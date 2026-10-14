import 'package:flutter/material.dart';

import 'chapters/registry.dart';
import 'core/chapter_screen.dart';

/// หน้าแรก: รายการบท 7-13 — แต่ละบทคือแลปที่รันได้ + โค้ดพร้อมคำอธิบาย
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แลปทบทวน Flutter บทที่ 7–13')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'แต่ละบทคือแลปที่รันได้จริง · อ่านโค้ดในแท็บไฟล์ — คอมเมนต์อธิบายทุกส่วนว่า '
            'คืออะไร / ทำไม / จำเป็นไหม / ข้อดี / ข้อเสีย',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          for (final chapter in allChapters)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(radius: 24, child: Icon(chapter.icon)),
                title: Text(
                  '${chapter.label}: ${chapter.title}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  chapter.labs.isEmpty
                      ? '${chapter.subtitle}\nกำลังจัดทำ'
                      : '${chapter.subtitle}\n${chapter.labs.length} แลป',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  ChapterScreen.routeName,
                  arguments: chapter.number,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
