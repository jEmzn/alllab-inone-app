import 'package:flutter/material.dart';

import '../services/api_service.dart';

// ---------------------------------------------------------------------------
// [เฉพาะแลปนี้] แถบเลือก "โหมดเครือข่ายจำลอง" เหนือแอป
// [ทำไม]   ทดลองทุกสถานะ error ได้โดยไม่ต้องถอดเน็ต — เลือกโหมด แล้วกด "ลองใหม่" /
//          ลากรีเฟรช / กดปุ่ม refresh ในแอปด้านล่าง (ไม่เกี่ยวกับข้อสอบ ไม่ต้องจำ)
// ---------------------------------------------------------------------------
class NetworkModeBar extends StatefulWidget {
  const NetworkModeBar({super.key, required this.child});
  final Widget child;

  @override
  State<NetworkModeBar> createState() => _NetworkModeBarState();
}

class _NetworkModeBarState extends State<NetworkModeBar> {
  static const _labels = {
    LabNetworkMode.real: 'เครือข่ายจริง (jsonplaceholder)',
    LabNetworkMode.fakeOk: 'จำลอง: สำเร็จ 200 รายการ (ไม่ใช้เน็ต)',
    LabNetworkMode.offline: 'จำลอง: ไม่มีสัญญาณ',
    LabNetworkMode.slow: 'จำลอง: ช้าเกิน (รอ 10 วิ → timeout)',
    LabNetworkMode.server500: 'จำลอง: เซิร์ฟเวอร์ 500',
    LabNetworkMode.notFound: 'จำลอง: 404 (ลองใหม่ไม่ช่วย)',
    LabNetworkMode.badJson: 'จำลอง: ได้ HTML แทน JSON',
  };

  @override
  void dispose() {
    // คืนค่าเริ่มต้น กันโหมดจำลองค้างไปแลปอื่น
    labNetworkMode = LabNetworkMode.real;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<LabNetworkMode>(
            isExpanded: true,
            value: labNetworkMode,
            items: [
              for (final e in _labels.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => labNetworkMode = v ?? LabNetworkMode.real),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
