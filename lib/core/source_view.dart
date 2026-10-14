import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// สีของโค้ด (ธีมมืดคงที่ อ่านง่ายทั้งโหมดสว่าง/มืด)
class _C {
  static const background = Color(0xFF1E2230);
  static const plain = Color(0xFFD6DBE8);
  static const keyword = Color(0xFFFF8FB1);
  static const string = Color(0xFFA5E075);
  static const comment = Color(0xFF8FB4D9);
  static const number = Color(0xFFF2B866);
  static const type = Color(0xFF7FC8F8);
  static const lineNo = Color(0xFF5A647C);
}

const _keywords = {
  'import', 'class', 'extends', 'with', 'implements', 'static', 'const',
  'final', 'var', 'late', 'void', 'return', 'if', 'else', 'for', 'while',
  'await', 'async', 'new', 'this', 'super', 'null', 'true', 'false', 'try',
  'catch', 'finally', 'throw', 'on', 'required', 'override', 'factory',
  'get', 'set', 'enum', 'is', 'as', 'in', 'switch', 'case', 'default',
  'dynamic', 'mixin', 'typedef', 'show', 'hide', 'sealed', 'abstract',
  'CREATE', 'TABLE', 'INTEGER', 'PRIMARY', 'KEY', 'AUTOINCREMENT', 'TEXT',
  'NOT', 'NULL', 'REAL', 'SELECT', 'FROM', 'WHERE', 'INSERT', 'INTO',
  'UPDATE', 'DELETE', 'ALTER', 'ADD', 'COLUMN', 'SUM',
};

final _token = RegExp(
  r'(//.*$)|' // 1 คอมเมนต์
  r'("(?:[^"\\]|\\.)*"|' "'" r"(?:[^'\\]|\\.)*')|" // 2 สตริง
  r'(\b\d+(?:\.\d+)?\b)|' // 3 ตัวเลข
  r'(\b[A-Za-z_][A-Za-z0-9_]*\b)', // 4 identifier
);

/// แท็กในคอมเมนต์ที่ใช้ทั้งโปรเจกต์ — ระบายสีให้เด่นเพื่อสแกนหาได้เร็ว
/// [คืออะไร] [ทำไม] [จำเป็น?] [ข้อดี] [ข้อเสีย] [ผลลัพธ์] [ทางเลือก] [ข้อสอบ]
final _tag = RegExp(r'\[(คืออะไร|ทำไม|จำเป็น\?|ข้อดี|ข้อเสีย|ผลลัพธ์|ทางเลือก|ข้อสอบ)\]');

const _tagColors = {
  'คืออะไร': Color(0xFF7FC8F8),
  'ทำไม': Color(0xFFF2B866),
  'จำเป็น?': Color(0xFFFF8FB1),
  'ข้อดี': Color(0xFFA5E075),
  'ข้อเสีย': Color(0xFFFF9E7A),
  'ผลลัพธ์': Color(0xFFC5A3FF),
  'ทางเลือก': Color(0xFF7FE0D0),
  'ข้อสอบ': Color(0xFFFFE066),
};

List<InlineSpan> _commentSpans(String comment) {
  final spans = <InlineSpan>[];
  var index = 0;
  for (final m in _tag.allMatches(comment)) {
    if (m.start > index) {
      spans.add(TextSpan(text: comment.substring(index, m.start)));
    }
    spans.add(TextSpan(
      text: m.group(0),
      style: TextStyle(
        color: _tagColors[m.group(1)] ?? _C.comment,
        fontWeight: FontWeight.w800,
      ),
    ));
    index = m.end;
  }
  if (index < comment.length) spans.add(TextSpan(text: comment.substring(index)));
  return spans;
}

/// ระบายสีหนึ่งบรรทัดด้วย RegExp (ไม่ใช้แพ็กเกจ syntax highlight)
List<InlineSpan> tintLine(String line) {
  final spans = <InlineSpan>[];
  var index = 0;
  for (final m in _token.allMatches(line)) {
    if (m.start > index) {
      spans.add(TextSpan(text: line.substring(index, m.start)));
    }
    final text = m.group(0)!;
    if (m.group(1) != null) {
      spans.add(TextSpan(
        style: const TextStyle(color: _C.comment),
        children: _commentSpans(text),
      ));
    } else {
      Color? color;
      if (m.group(2) != null) {
        color = _C.string;
      } else if (m.group(3) != null) {
        color = _C.number;
      } else if (_keywords.contains(text)) {
        color = _C.keyword;
      } else if (RegExp(r'^[A-Z]').hasMatch(text)) {
        color = _C.type;
      }
      spans.add(TextSpan(text: text, style: color == null ? null : TextStyle(color: color)));
    }
    index = m.end;
  }
  if (index < line.length) spans.add(TextSpan(text: line.substring(index)));
  return spans;
}

/// โหลดซอร์สไฟล์จริงจาก asset แล้วแสดงพร้อมคอมเมนต์อธิบาย
class SourceView extends StatefulWidget {
  const SourceView({super.key, required this.path});
  final String path;

  @override
  State<SourceView> createState() => _SourceViewState();
}

class _SourceViewState extends State<SourceView> {
  // สร้าง Future ครั้งเดียวใน initState (บทที่ 12: ห้ามเริ่มงาน async ใน build)
  late final Future<String> _source = rootBundle.loadString(widget.path);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _source,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('อ่านไฟล์ไม่ได้: ${widget.path}\n${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SourceText(path: widget.path, source: snapshot.data!);
      },
    );
  }
}

class SourceText extends StatelessWidget {
  const SourceText({super.key, required this.path, required this.source});
  final String path;
  final String source;

  static const _base = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.5,
    height: 1.5,
    color: _C.plain,
  );

  @override
  Widget build(BuildContext context) {
    final lines = source.trimRight().split('\n');
    return Container(
      color: _C.background,
      child: SelectionArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 12, 12, 32),
          itemCount: lines.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 10),
                child: Text(
                  path.replaceFirst('lib/', ''),
                  style: _base.copyWith(color: _C.number, fontWeight: FontWeight.w700),
                ),
              );
            }
            final line = lines[i - 1];
            final isComment = line.trimLeft().startsWith('//');
            return Container(
              color: isComment ? const Color(0x143C7BFF) : null,
              padding: const EdgeInsets.symmetric(vertical: 0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '$i',
                      textAlign: TextAlign.right,
                      style: _base.copyWith(color: _C.lineNo, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(style: _base, children: tintLine(line.isEmpty ? ' ' : line)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
