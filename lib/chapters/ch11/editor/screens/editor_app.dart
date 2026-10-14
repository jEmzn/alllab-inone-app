import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';
import 'edit_item_screen.dart';
import 'item_list_screen.dart';

// ============================================================================
// แลปบทที่ 11 (ปฏิบัติการที่ 1): provider_editor_lab  (ไฟล์นี้ = main.dart)
//
// โครงสร้างโปรเจกต์ (ตามขั้นตอนที่ 1):  models/ providers/ screens/
//   editor/models/item.dart                  ← ข้อมูล
//   editor/providers/item_provider.dart      ← state + ตรรกะ (ChangeNotifier)
//   editor/screens/item_list_screen.dart     ← หน้ารายการ (Consumer)
//   editor/screens/edit_item_screen.dart     ← หน้าแก้ไข (context.read)
//   editor/screens/editor_app.dart           ← (ไฟล์นี้) ประกอบทั้งหมด
//
// สิ่งที่ต้องได้จากแลปนี้:
//   - provider เดียวแชร์ข้อมูลข้าม 2 หน้า โดยไม่ส่งค่าผ่าน constructor/pop
//   - Consumer ตีกรอบ rebuild ให้แคบ (ดู Debug Console เทียบ build กับ builder)
// ============================================================================
class Ch11EditorLabApp extends StatelessWidget {
  const Ch11EditorLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] ของจริงคือ runApp(ChangeNotifierProvider(create: ..., child: MyApp()))
    //          ที่นี่ย้ายมาห่อ MaterialApp (ผลเท่ากัน — อยู่เหนือทุกหน้าใน Navigator)
    // [ข้อสอบ] ต้องอยู่ "เหนือ" MaterialApp หรือเหนือ Navigator เสมอ ไม่เช่นนั้น
    //          หน้าที่ถูก push ใหม่จะหา provider ไม่เจอ (ProviderNotFoundException)
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: MaterialApp(
        title: 'Provider Editor Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        initialRoute: ItemListScreen.routeName,
        routes: {
          ItemListScreen.routeName: (context) => const ItemListScreen(),
          EditItemScreen.routeName: (context) => const EditItemScreen(),
        },
      ),
    );
  }
}
