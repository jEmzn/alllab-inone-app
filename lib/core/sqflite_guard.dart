import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// sqflite ที่ตำราสอนรองรับเฉพาะ Android / iOS (และ macOS) —
/// บน Linux / Windows / Web ต้องใช้แพ็กเกจเสริมที่ "ไม่มีในบทเรียน" จึงไม่ใช้
bool get sqfliteSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// ห่อแลปที่ใช้ sqflite: ถ้าแพลตฟอร์มไม่รองรับ แสดงคำอธิบายแทนที่จะ crash
/// (MissingPluginException ตอนเรียก openDatabase) — โค้ดแลปจริงไม่ต้องมีส่วนนี้
class SqfliteGuard extends StatelessWidget {
  const SqfliteGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (sqfliteSupported) return child;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 56),
              const SizedBox(height: 12),
              Text(
                'แลปนี้ใช้ sqflite จริง จึงรันได้เฉพาะ Android / iOS',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'แพลตฟอร์มนี้ไม่มี SQLite plugin ของ sqflite\n'
                'รันแอปนี้บน emulator/เครื่องจริง (flutter run -d <android>) '
                'หรืออ่านโค้ดในแท็บไฟล์ได้ตามปกติ',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
