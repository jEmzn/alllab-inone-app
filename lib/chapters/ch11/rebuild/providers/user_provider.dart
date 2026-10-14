import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, Colors;

// ============================================================================
// UserProvider (provider_consumer_demo, หัวข้อ 11.2)
//
// [คืออะไร] provider ที่มี "หลายฟิลด์" และมีเมธอดที่เปลี่ยนคนละฟิลด์
// [ทำไม]   จงใจออกแบบให้ทดลองได้ว่าวิดเจ็ตแต่ละแบบ (watch / Consumer / select)
//          rebuild เมื่อไร — ถ้ามีฟิลด์เดียว select กับ watch จะให้ผลเหมือนกัน แยกไม่ออก
// ============================================================================
class UserProvider extends ChangeNotifier {
  String _nickname = 'ต้นกล้า';
  final String _realName = 'ณัฐพงษ์ ใจดี';
  // [ทำไม] ใช้สีแทน profileImageUrl ของตำรา เพื่อไม่ต้องพึ่งอินเทอร์เน็ตตอนทดลอง
  Color _avatarColor = Colors.indigo; // แทน profileImageUrl ในตำรา (ไม่ต้องพึ่งเน็ต)
  int _editCount = 0;

  String get nickname => _nickname;
  String get realName => _realName;
  Color get avatarColor => _avatarColor;

  // เปลี่ยนเฉพาะ 'ชื่อเล่น'
  void changeNickname() {
    _editCount++;
    _nickname = 'ต้นกล้า คนที่ $_editCount';
    notifyListeners();
  }

  // เปลี่ยนเฉพาะ 'สีรูปโปรไฟล์' — ใช้พิสูจน์ว่า select(nickname) ไม่ถูกปลุกโดยฟิลด์อื่น
  void changeAvatarColor() {
    _avatarColor = _avatarColor == Colors.indigo ? Colors.teal : Colors.indigo;
    notifyListeners();
  }
}
