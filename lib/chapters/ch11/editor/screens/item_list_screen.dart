import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';
import 'edit_item_screen.dart';

// ============================================================================
// ItemListScreen — หน้าหลัก: แสดงรายการ และ "ฟัง" การเปลี่ยนแปลง (ขั้นตอนที่ 4)
//
// [คืออะไร] StatelessWidget — หน้านี้ไม่มี state ของตัวเอง ข้อมูลทั้งหมดอยู่ใน provider
// ============================================================================
class ItemListScreen extends StatelessWidget {
  static const String routeName = '/';
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [คืออะไร] พิมพ์ทุกครั้งที่ build ของหน้านี้ทำงาน (ทดลองต่อยอดท้ายแลป)
    // [ผลลัพธ์] ปรากฏ "ครั้งเดียว" ตอนเปิดหน้า · ไม่ปรากฏซ้ำเมื่อแก้สินค้า
    //          เพราะ rebuild ถูกตีกรอบไว้ที่ Consumer ด้านล่าง ไม่ลามมาถึง build นี้
    debugPrint('ItemListScreen.build() ถูกเรียก');

    return Scaffold(
      appBar: AppBar(title: const Text('รายการสินค้า')),

      // [คืออะไร] Consumer<T> = วิดเจ็ตที่ "ฟัง" provider ชนิด T แล้วเรียก builder ใหม่
      //          ทุกครั้งที่ notifyListeners()
      // [ทำไม]   ใช้แทน context.watch เมื่ออยากตีกรอบ "พื้นที่ที่ rebuild" ให้แคบ
      //          (ที่นี่ build ของ Scaffold/AppBar ไม่ต้องทำใหม่)
      // [ข้อสอบ] builder รับ 3 พารามิเตอร์: (context, provider, child)
      //          child = วิดเจ็ตที่ไม่ต้อง rebuild (ส่งทาง child: ของ Consumer)
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          debugPrint('Consumer.builder ถูกเรียก');
          // [ข้อเสีย] ห่อ ListView ทั้งก้อน = แก้สินค้าชิ้นเดียว ทุกแถว rebuild
          //          แลปนี้มี 3 แถว ไม่เป็นไร · ถ้ามีหลายร้อยแถว ย้าย Consumer/Selector
          //          ลงไปใน itemBuilder (ดูแลป provider_shop)
          return ListView.builder(
            itemCount: itemProvider.items.length,
            itemBuilder: (context, index) {
              final item = itemProvider.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // [คืออะไร] ส่งอ็อบเจกต์ Item ทั้งก้อนไปกับ named route (บทที่ 9)
                  // [ข้อเสีย] arguments เป็น Object? ไม่ถูกตรวจชนิดตอนคอมไพล์
                  //          และหน้าแก้ไขถือ "ตัว Item จริง" ที่ provider ถืออยู่ (ดูข้อควรระวังที่ item.dart)
                  Navigator.pushNamed(
                    context,
                    EditItemScreen.routeName,
                    arguments: item,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
