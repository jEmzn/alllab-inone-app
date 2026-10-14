import 'package:flutter/material.dart';

/// หนึ่งแลป = แอปเล็ก ๆ ที่รันได้จริง + ไฟล์ซอร์สที่ใช้ประกอบมัน
/// (ซอร์สที่แสดงในแอปคือไฟล์จริงที่ถูก compile — ไม่มีสำเนาแยก)
class Lab {
  const Lab({
    required this.id,
    required this.title,
    required this.goal,
    required this.tryThis,
    required this.files,
    required this.entry,
  });

  final String id;
  final String title;

  /// แลปนี้ต้องการให้เข้าใจอะไร
  final String goal;

  /// ลองทำอะไรในแอปที่รันอยู่
  final List<String> tryThis;

  /// path ของไฟล์ซอร์ส (ต้องประกาศเป็น asset ใน pubspec.yaml)
  /// ไฟล์แรกคือไฟล์ที่ควรอ่านก่อน
  final List<String> files;

  /// วิดเจ็ตเริ่มต้นของแลป — เทียบได้กับ main.dart ของโปรเจกต์แลปในตำรา
  final WidgetBuilder entry;
}

class LabChapter {
  const LabChapter({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.labs,
  });

  final int number;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Lab> labs;

  String get label => 'บทที่ $number';
}

/// อาร์กิวเมนต์ของ route '/lab'
class LabArgs {
  const LabArgs(this.chapterNumber, this.labIndex);
  final int chapterNumber;
  final int labIndex;
}
