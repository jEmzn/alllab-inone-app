import 'package:flutter/material.dart';

// ============================================================================
// แลปบทที่ 10 (ก่อน refactor): ตัวนับด้วย setState — จุดเริ่มต้นของแลป
//
// เปิดไฟล์นี้เทียบกับ provider_counter_app.dart ทีละบรรทัดเพื่อดูว่า "อะไรย้ายไปไหน":
//
//   ตัวแปร _counter           →  CounterProvider._count
//   _incrementCounter()       →  CounterProvider.increment() (+ notifyListeners)
//   setState(...)             →  notifyListeners()
//   Text('$_counter')         →  context.watch<CounterProvider>().count
//   onPressed: _increment...  →  context.read<CounterProvider>().increment()
// ============================================================================
class SetStateCounterApp extends StatelessWidget {
  const SetStateCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Counter (setState)',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const _MyHomePage(title: 'setState Counter'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({required this.title});
  final String title;

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  // [คืออะไร] state อยู่ในวิดเจ็ตนี้เอง (ephemeral state — บทที่ 7)
  // [ข้อดี]   เรียบง่ายที่สุดสำหรับ state ที่ใช้หน้าเดียว
  // [ข้อเสีย] วิดเจ็ตอื่น/หน้าอื่นเข้าถึงค่านี้ไม่ได้ นอกจากไล่ส่งผ่าน constructor + callback
  //          และ UI กับตรรกะปนอยู่ในคลาสเดียวกัน (ทดสอบยาก)
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
