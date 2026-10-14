import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';
import '../providers/user_profile_provider.dart';
import 'edit_item_screen.dart';
import 'item_list_screen.dart';

// ============================================================================
// แลปบทที่ 11 (ปฏิบัติการที่ 2): provider_shop  (ไฟล์นี้ = main.dart)
//
// เป้าหมาย: Provider หลายตัวใน MultiProvider · Consumer/select/Selector ·
//           ฟอร์มแก้ไขที่เรียก provider
// ============================================================================
class Ch11ShopLabApp extends StatelessWidget {
  const Ch11ShopLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] MultiProvider = รวม provider หลายตัวเป็น "รายการ" แทนการซ้อน
    //          ChangeNotifierProvider เป็นชั้น ๆ (Pyramid of Doom)
    // [ทำไม]   ไม่ได้เร็วขึ้นหรือเปลี่ยนวิธีทำงาน — ได้แค่ "อ่านง่าย/แก้ง่าย" ระยะยาว
    //          (เพิ่ม/ลบ provider = แก้บรรทัดเดียว ไม่กระทบการเยื้องของโค้ดอื่น)
    // [ข้อสอบ] เบื้องหลังก็ยังซ้อนเป็นชั้นเหมือนเดิม จึง
    //          (1) ลำดับมีความหมาย: provider ที่ประกาศก่อนอยู่ชั้นบน — ตัวที่ต้องอ่านอีกตัว
    //              ต้องประกาศ "หลัง" ตัวนั้น (ความท้าทายข้อ 3: ลองสลับลำดับดู — ตอนนี้
    //              สองตัวไม่พึ่งกัน จึงสลับได้ ต้องมี ProxyProvider ถ้าพึ่งกัน)
    //          (2) สร้างแบบ lazy: create ยังไม่ทำงานจนมีใครขอใช้ (ตั้ง lazy: false ถ้าต้องเริ่มทันที)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ItemProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Provider Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.purple),
        initialRoute: '/',
        routes: {
          ItemListScreen.routeName: (ctx) => const ItemListScreen(),
          EditItemScreen.routeName: (ctx) => const EditItemScreen(),
        },
      ),
    );
  }
}
