import 'package:flutter/material.dart';

import 'lab.dart';
import 'lab_screen.dart';

/// หน้ารวมแลปของบท
class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key, required this.chapter});
  final LabChapter chapter;

  static const routeName = '/chapter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${chapter.label}: ${chapter.title}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(chapter.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          if (chapter.labs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('แลปของบทนี้กำลังจัดทำ'),
              ),
            ),
          for (var i = 0; i < chapter.labs.length; i++)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const CircleAvatar(child: Icon(Icons.science)),
                title: Text(
                  chapter.labs[i].title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(chapter.labs[i].goal),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  LabScreen.routeName,
                  arguments: LabArgs(chapter.number, i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
