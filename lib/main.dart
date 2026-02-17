import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- ข้อมูล Supabase ของคุณ ---
const supabaseUrl = 'https://fajvqzaixylibqpvdtml.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhanZxemFpeHlsaWJxcHZkdG1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyOTk5MjUsImV4cCI6MjA4Njg3NTkyNX0.X4bZqvKi_Rp5mhLDeoNSniNXVoF3312ro4EfDikUlDQ';
// ----------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Menu Catalog',
      theme: ThemeData(
        useMaterial3: true,
        // สีหลักเป็นสีน้ำตาลกาแฟ
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F4E37),
          primary: const Color(0xFF6F4E37),
          secondary: const Color(0xFFD7CCC8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // พื้นหลังสีขาวครีม
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent, // AppBar โปร่งใส
          foregroundColor: Color(0xFF6F4E37), // ตัวหนังสือสีน้ำตาล
        ),
      ),
      home: const MenuCatalogScreen(),
    );
  }
}

class MenuCatalogScreen extends StatefulWidget {
  const MenuCatalogScreen({Key? key}) : super(key: key);

  @override
  State<MenuCatalogScreen> createState() => _MenuCatalogScreenState();
}

class _MenuCatalogScreenState extends State<MenuCatalogScreen> {
  // Stream ดึงข้อมูล
  final _coffeeStream = Supabase.instance.client
      .from('coffee_menus')
      .stream(primaryKey: ['id'])
      .order('id', ascending: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OUR COFFEE MENU',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _coffeeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee_maker_outlined, size: 80, color: Colors.brown[200]),
                  const SizedBox(height: 16),
                  Text('ยังไม่มีรายการเมนู', style: TextStyle(color: Colors.brown[300], fontSize: 18)),
                ],
              ),
            );
          }

          final coffees = snapshot.data!;

          // ใช้ GridView แสดงผลแบบตาราง (2 คอลัมน์)
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 การ์ดต่อแถว
              childAspectRatio: 0.75, // อัตราส่วน กว้าง:สูง ของการ์ด
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: coffees.length,
            itemBuilder: (context, index) {
              final coffee = coffees[index];
              return _buildCoffeeCard(coffee);
            },
          );
        },
      ),
      // ปุ่มลอยสวยๆ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFF6F4E37),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Menu', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- Widget: การ์ดสินค้า ---
  Widget _buildCoffeeCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. เนื้อหาหลัก
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนรูปภาพ (ด้านบน)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.coffee,
                      size: 64,
                      color: Colors.brown[300],
                    ),
                  ),
                ),
              ),
              // ส่วนข้อมูล (ด้านล่าง)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        '${item['price']} ฿',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. ปุ่มลบ (มุมขวาบน)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => _deleteMenu(item['id']),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic: เพิ่มเมนู ---
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มเมนูใหม่'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: _inputStyle('ชื่อเมนู', Icons.coffee)),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl, 
              decoration: _inputStyle('ราคา (บาท)', Icons.attach_money), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: _inputStyle('รายละเอียดสั้นๆ', Icons.description)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6F4E37), foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await Supabase.instance.client.from('coffee_menus').insert({
                  'name': nameCtrl.text,
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'description': descCtrl.text,
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('เพิ่มสินค้า'),
          ),
        ],
      ),
    );
  }

  // Helper สำหรับแต่งกล่องข้อความ
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.brown[300]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.brown[50],
    );
  }

  // --- Logic: ลบเมนู ---
  Future<void> _deleteMenu(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: const Text('คุณต้องการลบเมนูนี้ออกจากร้านใช่หรือไม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('ลบเลย', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await Supabase.instance.client.from('coffee_menus').delete().eq('id', id);
    }
  }
}
