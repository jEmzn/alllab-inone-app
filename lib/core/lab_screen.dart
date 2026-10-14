import 'package:flutter/material.dart';

import 'lab.dart';
import 'source_view.dart';

/// หน้าแลป: แท็บ "รันดู" (แอปแลปที่ทำงานจริง) + แท็บซอร์สทีละไฟล์
class LabScreen extends StatelessWidget {
  const LabScreen({super.key, required this.chapter, required this.lab});
  final LabChapter chapter;
  final Lab lab;

  static const routeName = '/lab';

  static String _fileName(String path) => path.split('/').last;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: lab.files.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${chapter.label}: ${lab.title}'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(icon: Icon(Icons.play_arrow), text: 'รันดู'),
              for (final f in lab.files) Tab(icon: const Icon(Icons.code), text: _fileName(f)),
            ],
          ),
        ),
        body: TabBarView(
          // ปิดการปัดข้ามแท็บ เพราะแลปมี Slider/ListView ที่ต้องใช้ท่าทางปัดเอง
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _KeepAlive(child: _RunTab(lab: lab)),
            for (final f in lab.files) SourceView(path: f),
          ],
        ),
      ),
    );
  }
}

class _RunTab extends StatelessWidget {
  const _RunTab({required this.lab});
  final Lab lab;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          color: scheme.surfaceContainerHigh,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              title: const Text('แลปนี้ต้องการให้เข้าใจอะไร / ลองทำอะไร (แตะเพื่อเปิด)'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lab.goal, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 8),
                for (final t in lab.tryThis)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('👉 '),
                        Expanded(child: Text(t, style: const TextStyle(height: 1.4))),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'อ่านคำอธิบายได้ที่แท็บไฟล์ด้านบน (คอมเมนต์ในโค้ดตัวที่รันอยู่นี้)',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
        // ขอบเขตของแอปแลป: แยกเป็นอีกแอปหนึ่ง (มี Navigator/Theme ของตัวเอง)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.primary, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Builder(builder: lab.entry),
          ),
        ),
      ],
    );
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
