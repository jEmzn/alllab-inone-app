import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

// ============================================================================
// แลปบทที่ 11 (หัวข้อ 11.2-11.5): Rebuild Lab — "พิสูจน์ด้วยการวัด"
//
// เลือกวิธีรับฟังด้านบน แล้วกด 2 ปุ่มด้านล่าง ดูตัวเลข "build ×n" ใต้แต่ละส่วน
// ตัวเลขเพิ่ม = ส่วนนั้นถูกสร้างใหม่ (ตัวเลขที่ไม่ขยับ = ไม่ถูกสร้างใหม่)
//
// บันไดการรับฟัง (กว้าง → แคบ):
//   read   : ไม่รับฟังเลย            (ใช้ใน callback)
//   watch  : ทั้งเมธอด build          (ง่ายสุด)
//   Consumer: เฉพาะพื้นที่ที่ห่อไว้
//   select : เฉพาะ "ค่า" ที่ระบุ
// [ข้อสอบ] เริ่มจากแบบที่อ่านง่าย (watch/Consumer) ก่อน แล้วค่อยแคบลงเมื่อ "วัดแล้ว" พบปัญหาจริง
//          — ไม่ใช่ใส่ select ทุกที่ตั้งแต่ต้น (ซับซ้อนขึ้นโดยไม่มีหลักฐานว่าจำเป็น)
// ============================================================================
class Ch11RebuildLabApp extends StatelessWidget {
  const Ch11RebuildLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const _LabHome(),
      ),
    );
  }
}

class _LabHome extends StatefulWidget {
  const _LabHome();

  @override
  State<_LabHome> createState() => _LabHomeState();
}

class _LabHomeState extends State<_LabHome> {
  int _variant = 0;

  static const _titles = ['1 watch', '2 Consumer', '3 Consumer+child', '4 select'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ทดลองขอบเขตการ rebuild')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // [คืออะไร] SegmentedButton (Material 3) เลือกได้ทีละตัว
            SegmentedButton<int>(
              segments: [
                for (var i = 0; i < _titles.length; i++)
                  ButtonSegment(value: i, label: Text(_titles[i], style: const TextStyle(fontSize: 11))),
              ],
              selected: {_variant},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _variant = s.first),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: switch (_variant) {
                  0 => const _WatchVariant(),
                  1 => const _ConsumerVariant(),
                  2 => const _ConsumerChildVariant(),
                  _ => const _SelectVariant(),
                },
              ),
            ),
            const Divider(),
            // ปุ่มสั่งงาน: ใช้ context.read เสมอ เพราะปุ่มไม่ต้อง rebuild ตาม state
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => context.read<UserProvider>().changeNickname(),
                  child: const Text('เปลี่ยนชื่อเล่น'),
                ),
                FilledButton.tonal(
                  onPressed: () => context.read<UserProvider>().changeAvatarColor(),
                  child: const Text('เปลี่ยนสีรูป'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// เครื่องมือวัด: _Counted
// ---------------------------------------------------------------------------
// [คืออะไร] ห่อส่วนใดก็ได้ แล้วนับว่า "ส่วนนั้นถูก build กี่ครั้ง" แสดงเป็นตัวเลขบนจอ
// [ทำไม]   ตำราใช้ print ใน build (ระดับ 1 ของการวัด) · ที่นี่แสดงบนจอให้เห็นง่ายกว่า
// [ข้อควรระวัง] การเพิ่ม _n ใน build เป็น side effect — ใช้เพื่อ "วัด" เท่านั้น
//          โค้ดจริงห้ามให้ build เปลี่ยน state · และไม่ใช่ setState จึงไม่ทำให้ลูป rebuild
class _Counted extends StatefulWidget {
  const _Counted({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  int _n = 0;

  @override
  Widget build(BuildContext context) {
    _n++;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.child,
        Text(
          '${widget.label}: build ×$_n',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.deepOrange),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// แบบที่ 1: context.watch  (ตำรา: UserProfileWidget)
// ---------------------------------------------------------------------------
// [คืออะไร] watch ที่บนสุดของ build → ทั้งวิดเจ็ตสร้างใหม่ทุกครั้งที่ notifyListeners
// [ผลลัพธ์] กดอะไรก็ได้ → ทุกตัวเลข (รูป/ชื่อจริง/ชื่อเล่น) เพิ่มพร้อมกัน
// [ข้อดี]   เขียนง่ายที่สุด · [ข้อเสีย] สร้างส่วนที่ไม่เปลี่ยน (รูป ชื่อจริง) ใหม่โดยไม่จำเป็น
class _WatchVariant extends StatelessWidget {
  const _WatchVariant();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    debugPrint('UserProfileWidget build() ถูกเรียก!');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Counted(
          label: 'รูปโปรไฟล์',
          child: CircleAvatar(radius: 36, backgroundColor: user.avatarColor, child: const Icon(Icons.person, size: 36)),
        ),
        _Counted(label: 'ชื่อจริง', child: Text(user.realName, style: const TextStyle(fontSize: 22))),
        _Counted(label: 'ชื่อเล่น', child: Text('ชื่อเล่น: ${user.nickname}')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// แบบที่ 2: Consumer  (ตำรา: UserProfileWidgetEfficient)
// ---------------------------------------------------------------------------
// [คืออะไร] ห่อ Consumer เฉพาะส่วนที่เปลี่ยนจริง (ชื่อเล่น) · ส่วนอื่นอ่านด้วย read
// [ผลลัพธ์] "ชื่อเล่น" เพิ่มทุกครั้งที่กด · รูป/ชื่อจริงไม่เพิ่ม
//          แต่ถ้ากด "เปลี่ยนสีรูป" ชื่อเล่นก็ยัง build เพิ่ม (Consumer ฟังทั้ง provider)
//          และรูปจะ "ไม่เปลี่ยนสี" เพราะอ่านด้วย read ครั้งเดียว ← ข้อควรระวังในตำรา
// [ข้อสอบ] ใช้ read กับค่าที่ "นิ่ง" เท่านั้น · ไม่แน่ใจ → เลือกฝั่งปลอดภัย (รับฟัง)
class _ConsumerVariant extends StatelessWidget {
  const _ConsumerVariant();

  @override
  Widget build(BuildContext context) {
    debugPrint('UserProfileWidgetEfficient build() ถูกเรียก!');
    final user = context.read<UserProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Counted(
          label: 'รูปโปรไฟล์ (read)',
          child: CircleAvatar(radius: 36, backgroundColor: user.avatarColor, child: const Icon(Icons.person, size: 36)),
        ),
        _Counted(label: 'ชื่อจริง (read)', child: Text(user.realName, style: const TextStyle(fontSize: 22))),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            debugPrint('Consumer สำหรับ "ชื่อเล่น" ถูกเรียก!');
            return _Counted(
              label: 'ชื่อเล่น (Consumer)',
              child: Text('ชื่อเล่น: ${userProvider.nickname}'),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// แบบที่ 3: Consumer + พารามิเตอร์ child
// ---------------------------------------------------------------------------
// [คืออะไร] วิดเจ็ตที่ส่งทาง `child:` ถูกสร้าง "ครั้งเดียว" แล้ว Consumer ส่งตัวเดิมกลับเข้า
//          builder ทุกครั้ง → ไม่ถูกสร้างใหม่
// [ทำไม]   เหมาะกับส่วนที่ "สร้างยากและไม่ขึ้นกับ state" (รูปใหญ่ กราฟ รายการซับซ้อน)
// [ผลลัพธ์] ตัวเลข "ป้ายยืนยัน (child)" ไม่เพิ่ม ขณะที่ "ชื่อเล่น" เพิ่ม
class _ConsumerChildVariant extends StatelessWidget {
  const _ConsumerChildVariant();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // [ข้อสอบ] const + ส่งทาง child → สร้างครั้งเดียวตอน Consumer ถูกสร้าง
      child: const _Counted(
        label: 'ป้ายยืนยัน (child)',
        child: Icon(Icons.verified, size: 40),
      ),
      builder: (context, user, child) {
        debugPrint('builder ทำงาน แต่ ExpensiveBadge ไม่ถูกสร้างใหม่');
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Counted(label: 'ชื่อเล่น (builder)', child: Text('ชื่อเล่น: ${user.nickname}')),
            const SizedBox(width: 16),
            child!, // นำวิดเจ็ตเดิมกลับมาใช้ซ้ำ
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// แบบที่ 4: context.select  (ตำรา: NicknameLabel)
// ---------------------------------------------------------------------------
// [คืออะไร] ฟังเฉพาะ "ค่า nickname" — ถ้า == ค่าเดิมก็ไม่ rebuild
// [ผลลัพธ์] กด "เปลี่ยนสีรูป" → ตัวเลขชื่อเล่น "ไม่เพิ่ม" (ต่างจากแบบที่ 2)
//          กด "เปลี่ยนชื่อเล่น" → เพิ่ม
// [ข้อสอบ] กับดัก: ค่าที่ select ต้องเทียบด้วย == ได้ (int/String/bool/double ได้)
//          ถ้าคืน List/Map/อ็อบเจกต์ที่ไม่ override == (เช่น `.map(...).toList()`)
//          จะ "ไม่เท่า" ทุกครั้ง → rebuild ทุกครั้ง แย่กว่า Consumer เสียอีก
// [ข้อสอบ] select ใช้ใน build เท่านั้น (ใน callback ใช้ read)
class _SelectVariant extends StatelessWidget {
  const _SelectVariant();

  @override
  Widget build(BuildContext context) {
    return const _NicknameLabel();
  }
}

class _NicknameLabel extends StatelessWidget {
  const _NicknameLabel();

  @override
  Widget build(BuildContext context) {
    final nickname = context.select<UserProvider, String>((p) => p.nickname);
    debugPrint('NicknameLabel build: $nickname');
    // _Counted อยู่ "ข้างใน" build นี้ → นับได้ว่า NicknameLabel ถูก rebuild กี่ครั้ง
    return _Counted(
      label: 'ชื่อเล่น (select)',
      child: Text('ชื่อเล่น: $nickname'),
    );
  }
}
