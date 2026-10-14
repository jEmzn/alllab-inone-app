import 'package:flutter/material.dart';

// ============================================================================
// LoginFormScreen — ฟอร์มล็อกอินฉบับสมบูรณ์ (ผลรวมของแบบฝึกหัด 1-5)
//
// ลำดับการต่อยอดในแลป:
//   1. Form + GlobalKey              → มีโครงฟอร์มที่สั่งตรวจ/บันทึกได้
//   2. TextFormField + Controller    → ช่องกรอก + ตัวควบคุม (ต้อง dispose)
//   3. validator + ปุ่ม Submit        → ตรวจความถูกต้อง
//   4. onSaved + save()              → เก็บค่าลงตัวแปร
//   5. ปรับให้ใช้บนมือถือจริง         → scroll, keyboard action, ซ่อน/แสดงรหัสผ่าน ฯลฯ
//
// ทำไมต้องเป็น StatefulWidget?
//   [คืออะไร] ฟอร์มมี state หลายอย่าง: controllers, ค่าที่บันทึก, สลับซ่อนรหัสผ่าน
//   [จำเป็น?] จำเป็น (มี controller ที่ต้อง dispose + มี setState ตอนสลับรหัสผ่าน)
// ============================================================================
class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  // -------------------------------------------------------------------------
  // แบบฝึกหัด 1: GlobalKey<FormState>
  // -------------------------------------------------------------------------
  // [คืออะไร] กุญแจพิเศษที่ผูกกับ Form เพื่อให้เรา "เอื้อมไปสั่ง" FormState
  //          (validate / save / reset) จากภายนอก Form ได้
  // [ทำไม]   ปุ่ม Submit อยู่นอก TextFormField จึงต้องมีทางเข้าถึงฟอร์ม
  // [จำเป็น?] จำเป็น ถ้าต้องการ validate()/save() ทั้งฟอร์มพร้อมกัน
  // [ข้อเสีย] GlobalKey มีต้นทุนสูงกว่า key ปกติเล็กน้อย → สร้างครั้งเดียวเก็บเป็น field
  //          (final) อย่าสร้างใหม่ใน build() เด็ดขาด ไม่งั้น state ของฟอร์มหาย
  final _formKey = GlobalKey<FormState>();

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 2: TextEditingController
  // -------------------------------------------------------------------------
  // [คืออะไร] ตัวถือข้อความของช่องกรอก อ่าน/แก้ค่าด้วยโค้ดได้ (.text, .clear())
  // [ทำไม]   ที่นี่ใช้เพื่อ "ล้างรหัสผ่าน" หลังส่งสำเร็จ (_passwordController.clear())
  // [จำเป็น?] ไม่จำเป็นทุกกรณี! ถ้าแค่ต้องการอ่านค่าตอนส่ง onSaved ก็พอแล้ว
  //          controller มีประโยชน์เมื่อต้องแก้/ล้างค่าด้วยโค้ดหรือฟังการเปลี่ยนแปลง
  // [ข้อเสีย] เป็นทรัพยากรที่ต้อง dispose เอง (ลืม = memory leak)
  // [ทางเลือก] ใช้ onSaved อย่างเดียว (ไม่มี controller) ถ้าไม่ต้องควบคุมค่าด้วยโค้ด
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 4: ตัวแปรเก็บค่าที่ "บันทึกแล้ว"
  // -------------------------------------------------------------------------
  // [คืออะไร] ปลายทางของ onSaved
  // [ทำไม]   แยกจาก controller เพื่อให้เห็นขั้นตอน validate → save ชัดเจน
  // [ข้อเสีย] ซ้ำซ้อนกับ controller.text (เก็บข้อมูลเดียวกันสองที่) — ในงานจริง
  //          เลือกใช้อย่างใดอย่างหนึ่งให้สอดคล้องกันทั้งแอป (หัวข้อ 8.11)
  String _savedEmail = '';
  String _savedPassword = '';

  // [คืออะไร] state ซ่อน/แสดงรหัสผ่าน → เปลี่ยนแล้วต้อง setState
  bool _obscurePassword = true;

  // [ข้อสอบ] สร้างใน initState, คืนใน dispose, ลำดับ super ตามที่เรียนในบทที่ 7
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // แบบฝึกหัด 3-5: _submit() — จุดรวมของการส่งฟอร์ม
  // -------------------------------------------------------------------------
  // [ทำไม]   ย้ายโค้ดออกจาก onPressed มาเป็นเมธอด เพราะต้องเรียกจาก 2 ที่:
  //          ปุ่มล็อกอิน และ onFieldSubmitted (กด "เสร็จ" บนคีย์บอร์ด)
  // [ข้อดี]   ไม่เขียนโค้ดซ้ำ, อ่านง่าย
  void _submit() {
    // [คืออะไร] ปิดคีย์บอร์ด (ถอดโฟกัสออกจากช่องกรอก)
    // [ทำไม]   คีย์บอร์ดที่ค้างอยู่จะบัง SnackBar และหน้าจอ
    FocusScope.of(context).unfocus();

    // [คืออะไร] currentState = FormState ปัจจุบัน (เป็น null ได้ถ้า Form ยังไม่อยู่ใน tree)
    // [ทำไม]   validate() เรียก validator ของ "ทุกช่อง" → true เมื่อผ่านหมด
    //          และสั่งให้ช่องที่ผิดโชว์ข้อความสีแดงเอง (เราไม่ต้องเรียก setState)
    // [ข้อควรระวัง] validate ต้องมาก่อน save เสมอ — ไม่ควรบันทึกค่าที่ยังไม่ผ่านตรวจ
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // [คืออะไร] save() เรียก onSaved ของทุกช่อง → ค่าไหลเข้า _savedEmail/_savedPassword
      _formKey.currentState!.save();

      // [คืออะไร] SnackBar แจ้งผลชั่วคราวที่ขอบล่าง แสดงผ่าน ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล็อกอินสำเร็จ! อีเมล: $_savedEmail')),
      );

      // [ข้อสอบ] "ห้ามพิมพ์รหัสผ่านจริง" ลง log/หน้าจอ (หัวข้อ 8.12) — log อ่านได้
      //          และ SnackBar อาจติดภาพหน้าจอ · พิมพ์แค่ความยาวก็พอยืนยันว่า onSaved ทำงาน
      // [คืออะไร] debugPrint ปลอดภัยกว่า print (ไม่โดนตัดข้อความยาว)
      debugPrint('อีเมลที่บันทึก: $_savedEmail');
      debugPrint('ความยาวรหัสผ่าน: ${_savedPassword.length} ตัวอักษร');

      // ล้างรหัสผ่านออกจากช่องหลังใช้งาน — นี่คือเหตุผลที่แลปนี้ยังมี controller
      _passwordController.clear();
    } else {
      debugPrint('ฟอร์มไม่ถูกต้อง');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ฟอร์มล็อกอิน')),

      // -----------------------------------------------------------------------
      // แบบฝึกหัด 5: SingleChildScrollView แทน Padding เฉย ๆ
      // -----------------------------------------------------------------------
      // [คืออะไร] ทำให้เนื้อหาเลื่อนได้
      // [ทำไม]   คีย์บอร์ดบนมือถือกินพื้นที่ครึ่งจอ ถ้าไม่เลื่อนได้ จะเกิดแถบลายเหลืองดำ
      //          (overflow) และปุ่มล็อกอินถูกบัง
      // [จำเป็น?] จำเป็นสำหรับฟอร์มบนมือถือจริง (ตอนทดสอบบนจอใหญ่อาจไม่เห็นปัญหา)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),

        // ---------------------------------------------------------------------
        // แบบฝึกหัด 1: Form
        // ---------------------------------------------------------------------
        // [คืออะไร] ตัวห่อกลุ่มช่องกรอก ให้ validate()/save() ได้ทีเดียวทั้งกลุ่ม
        // [ทำไม]   ถ้าไม่มี Form ต้องไล่เรียก validate ทีละช่องเอง
        // [ข้อสอบ] ใส่ key: _formKey ที่ Form (ไม่ใช่ที่ TextFormField)
        child: Form(
          key: _formKey,

          // [คืออะไร] กำหนดว่า "เมื่อไหร่" ให้ตรวจอัตโนมัติ
          //   onUserInteractionIfError = ยังไม่ตรวจจนกว่าจะกดส่งครั้งแรก หลังจากนั้น
          //   ช่องที่เคยมี error จะตรวจใหม่ทุกครั้งที่ผู้ใช้แก้ (error หายทันทีที่ถูก)
          // [ข้อดี]   ไม่ด่าผู้ใช้ตั้งแต่ยังพิมพ์ไม่เสร็จ แต่แก้แล้วเห็นผลทันที
          // [ทางเลือก] always = ตรวจตลอด (น่ารำคาญ) · disabled = ตรวจเมื่อเรียก validate() เท่านั้น
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,

          child: Column(
            // [ทำไม]   stretch ให้ปุ่มกว้างเต็มแถว
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('กรุณาป้อนข้อมูลเข้าระบบ:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // ===============================================================
              // ช่องอีเมล
              // ===============================================================
              // [คืออะไร] TextFormField = TextField + เป็น FormField (เข้าร่วม validate/save ได้)
              // [ทำไม]   ใช้ตัวนี้แทน TextField เมื่ออยู่ในฟอร์ม · TextField ธรรมดา
              //          Form มองไม่เห็น → validate()/save() ไม่ทำงานกับมัน
              TextFormField(
                controller: _emailController,

                // [คืออะไร] InputDecoration = หน้าตาของช่อง (label, hint, ไอคอน, ขอบ)
                // [จำเป็น?] ไม่จำเป็นต่อการทำงาน แต่ช่วย UX มาก
                // [ข้อดี]   labelText ลอยขึ้นเมื่อกรอก, hintText บอกตัวอย่างรูปแบบ
                // [ข้อเสีย] ช่องนี้ const ได้เพราะค่าไม่เปลี่ยน (ช่องรหัสผ่านทำไม่ได้ ดูด้านล่าง)
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),

                // [คืออะไร] ชนิดคีย์บอร์ด → แสดงปุ่ม @ และ . บนคีย์บอร์ดมือถือ
                keyboardType: TextInputType.emailAddress,

                // [คืออะไร] ปุ่ม action ของคีย์บอร์ด: next = "ถัดไป" โฟกัสกระโดดไปช่องถัดไป
                textInputAction: TextInputAction.next,

                // [คืออะไร] บอกระบบ autofill ของ OS ว่าช่องนี้คืออีเมล
                // [ข้อเสีย] บางแพลตฟอร์มต้องห่อ Form ด้วย AutofillGroup จึงจะทำงานเต็มที่
                autofillHints: const [AutofillHints.email],

                // [คืออะไร] validator: รับค่า (String?) คืน "ข้อความ error" ถ้าไม่ผ่าน
                //          หรือ null ถ้าผ่าน  ← จำกฎนี้ให้ได้ (ข้อสอบชอบถาม)
                // [ทำไม]   value เป็น String? เพราะ TextFormField ส่ง null ได้ จึงใช้ ?. / ??
                // [ข้อดี]   trim() ตัดช่องว่างหัวท้าย → " a@b.com " ผ่าน, "   " ถูกปฏิเสธ
                // [ข้อเสีย] เช็กแค่มี '@' กับ '.' หลวมมาก ("@." ก็ผ่าน) · ของจริงใช้ RegExp
                //          แต่ที่ตรวจจริงสุดคือส่งอีเมลยืนยันจากฝั่งเซิร์ฟเวอร์
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'กรุณาป้อนอีเมลของคุณ';
                  }
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'กรุณาป้อนที่อยู่อีเมลที่ถูกต้อง';
                  }
                  return null; // null = ผ่าน
                },

                // [คืออะไร] ถูกเรียกเมื่อ FormState.save() — รับค่าสุดท้ายของช่อง
                // [ข้อดี]   trim() ซ้ำตรงนี้ ให้ค่าที่เก็บสะอาดเหมือนที่ validator ตรวจ
                onSaved: (value) {
                  _savedEmail = value?.trim() ?? '';
                },
              ),
              const SizedBox(height: 15),

              // ===============================================================
              // ช่องรหัสผ่าน
              // ===============================================================
              TextFormField(
                controller: _passwordController,

                // [ทำไม]   decoration ช่องนี้ "ห้าม const" เพราะ suffixIcon เปลี่ยนตาม
                //          _obscurePassword (ค่าไดนามิก) — const ถูกเอาออกทั้งก้อน
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  hintText: 'ป้อนรหัสผ่านของคุณ',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),

                  // [คืออะไร] ปุ่มรูปตาท้ายช่อง สลับซ่อน/แสดงรหัสผ่าน
                  // [ทำไม]   พิมพ์รหัสผ่านบนมือถือพลาดง่าย ให้ผู้ใช้ตรวจเองได้
                  // [ข้อดี]   UX ดีขึ้น · ใช้ setState (บทที่ 7) กับ state เล็ก ๆ ในหน้าเดียว
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    tooltip: _obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                // [คืออะไร] ซ่อนตัวอักษรเป็นจุด ● ผูกกับ state
                obscureText: _obscurePassword,

                // done = ปุ่ม "เสร็จ" · onFieldSubmitted ทำงานเมื่อกดปุ่มนั้น
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],

                // [ทำไม]   ช่องสุดท้ายกด "เสร็จ" แล้วส่งฟอร์มเลย (ไม่ต้องไปกดปุ่ม)
                // [คืออะไร] (_) = พารามิเตอร์ที่ไม่ใช้ (ค่าข้อความ)
                onFieldSubmitted: (_) => _submit(),

                // [ข้อสอบ] ไม่ trim รหัสผ่าน เพราะช่องว่างอาจเป็นส่วนหนึ่งของรหัสผ่านจริง
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาป้อนรหัสผ่านของคุณ';
                  }
                  if (value.length < 6) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  return null;
                },
                onSaved: (value) {
                  _savedPassword = value ?? '';
                },
              ),
              const SizedBox(height: 30),

              // [คืออะไร] ปุ่มส่งฟอร์ม ส่ง "_submit" (ไม่มีวงเล็บ) เป็น callback
              ElevatedButton(
                onPressed: _submit,
                child: const Text('ล็อกอิน'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
