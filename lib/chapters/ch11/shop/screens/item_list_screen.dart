import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/user_profile_provider.dart';
import 'edit_item_screen.dart';

// ============================================================================
// ItemListScreen (provider_shop) — หน้ารายการ
//
// โค้ดนี้ใช้ "ความท้าทาย" ของแลปแล้ว 2 ข้อ (แต่ละข้อมีโค้ดตำราต้นฉบับเป็นคอมเมนต์ไว้เทียบ):
//   ข้อ 1: ชื่อผู้ใช้ใน AppBar ใช้ context.select   (_UsernameTitle)
//   ข้อ 2: แต่ละแถวฟังข้อมูลของตัวเองด้วย Selector   (_ItemTile)
// ดู Debug Console: เห็นว่ากดอะไรแล้ว build ส่วนไหนทำงานบ้าง
// ============================================================================
class ItemListScreen extends StatelessWidget {
  static const routeName = '/';
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('ItemListScreen.build()');

    // [คืออะไร] select<ItemProvider, int>: ฟังเฉพาะ "จำนวนรายการ"
    // [ทำไม]   build หน้านี้ควรทำงานใหม่เมื่อจำนวนแถวเปลี่ยนเท่านั้น (เพิ่ม/ลบ)
    //          ไม่ใช่เมื่อแก้ชื่อสินค้า — int เทียบด้วย == ได้ตรงไปตรงมา
    final itemCount = context.select<ItemProvider, int>((p) => p.items.length);

    return Scaffold(
      appBar: AppBar(
        title: const _UsernameTitle(),
        actions: [
          // ปุ่มทดลอง: เปลี่ยนชื่อผู้ใช้ เพื่อดูว่า "ส่วนไหนบ้าง" rebuild
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'เปลี่ยนชื่อผู้ใช้',
            // [ข้อสอบ] onPressed → context.read (ไม่ listen)
            onPressed: () => context.read<UserProfileProvider>().changeUsername(
                  'Student${DateTime.now().millisecond}',
                ),
          ),
        ],
      ),

      // ----- ตำราต้นฉบับ (Consumer ห่อทั้ง ListView) -----
      // body: Consumer<ItemProvider>(
      //   builder: (ctx, itemProvider, child) => ListView.builder(
      //     itemCount: itemProvider.items.length,
      //     itemBuilder: (_, i) { final item = itemProvider.items[i]; return ListTile(...); },
      //   ),
      // ),
      // ข้อดีของต้นฉบับ: อ่านง่ายสุด · ข้อเสีย: แก้สินค้าชิ้นเดียว ทุกแถว rebuild
      //
      // ----- เวอร์ชันความท้าทายข้อ 2 (ด้านล่าง) -----
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, i) {
          // อ่าน id ครั้งเดียวด้วย read (ไม่ฟัง) แล้วให้แต่ละแถวฟังข้อมูลของ id ตัวเอง
          final id = context.read<ItemProvider>().items[i].id;
          return _ItemTile(id: id);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ความท้าทายข้อ 1: select เฉพาะชื่อผู้ใช้
// ---------------------------------------------------------------------------
// [ทำไม]   แยกเป็นวิดเจ็ตของตัวเอง เพื่อให้ "เฉพาะชื่อ AppBar" rebuild เมื่อชื่อผู้ใช้เปลี่ยน
// [คืออะไร] context.select<UserProfileProvider, String>((p) => p.username)
//          → rebuild ก็ต่อเมื่อ "ค่า username" เปลี่ยน (เทียบด้วย ==)
// [ข้อเสีย] UserProfileProvider ตอนนี้มีฟิลด์เดียว ผลต่างจาก watch จึงไม่เห็นชัด
//          select จะคุ้มเมื่อ provider มีหลายฟิลด์ที่เปลี่ยนไม่พร้อมกัน
// [ข้อสอบ] select ต้องเรียกใน build เท่านั้น และค่าที่เลือกต้องเทียบด้วย == ได้ตรงไปตรงมา
class _UsernameTitle extends StatelessWidget {
  const _UsernameTitle();

  @override
  Widget build(BuildContext context) {
    final username = context.select<UserProfileProvider, String>((p) => p.username);
    debugPrint('_UsernameTitle.build() username=$username');
    return Text('รายการสินค้า (ผู้ใช้: $username)');
  }
}

// ---------------------------------------------------------------------------
// ความท้าทายข้อ 2: Selector ต่อแถว
// ---------------------------------------------------------------------------
// [คืออะไร] Selector<T, R> = Consumer + select: กรองค่าก่อนตัดสินใจ rebuild
//          selector: เลือกค่า R จาก provider · builder: สร้าง UI จากค่าที่เลือก
// [ทำไม]   updateItem แทนที่ Item ด้วยอ็อบเจกต์ใหม่ → findById ของแถวที่ถูกแก้ได้
//          อินสแตนซ์ใหม่ (== ต่าง) จึง rebuild · แถวอื่นได้อินสแตนซ์เดิม จึงไม่ rebuild
// [ผลลัพธ์] แก้สินค้า 1 ชิ้น → console มี "_ItemTile build" แค่ 1 บรรทัด (ไม่ใช่ 3)
// [ข้อเสีย] โค้ดซับซ้อนกว่า Consumer · ถ้า Item override == แบบเทียบค่า ผลจะเปลี่ยนไป
class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Selector<ItemProvider, Item>(
      selector: (context, provider) => provider.findById(id),
      builder: (context, item, child) {
        debugPrint('_ItemTile build: ${item.name}');
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.description),
          trailing: Text('฿${item.price.toStringAsFixed(2)}'),
          onTap: () {
            // ส่งเฉพาะ id (String) ไปกับ route แล้วให้หน้าแก้ไขดึงข้อมูลล่าสุดจาก provider
            Navigator.of(context).pushNamed(
              EditItemScreen.routeName,
              arguments: item.id,
            );
          },
        );
      },
    );
  }
}
