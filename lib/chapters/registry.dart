import '../core/lab.dart';
import 'ch07/ch07_labs.dart';
import 'ch08/ch08_labs.dart';
import 'ch09/ch09_labs.dart';
import 'ch10/ch10_labs.dart';
import 'ch11/ch11_labs.dart';
import 'ch12/ch12_labs.dart';
import 'ch13/ch13_labs.dart';

/// รายการบททั้งหมด (บท 7–13)
final List<LabChapter> allChapters = [
  chapter07,
  chapter08,
  chapter09,
  chapter10,
  chapter11,
  chapter12,
  chapter13,
];

LabChapter? chapterByNumber(int n) {
  for (final c in allChapters) {
    if (c.number == n) return c;
  }
  return null;
}
