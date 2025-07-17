import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'custom_button.dart';
import 'product.dart';
import 'employee.dart';
import 'assignment.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';


Future<void> showDetailDialog(BuildContext context, String title, Map<String, dynamic> data) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.containsKey('ID') && data['ID'] != null && data['ID'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: data['ID'].toString(),
                    width: 200,
                    height: 60,
                  ),
                ),
              ),
            ...data.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Kapat'),
        ),
      ],
    ),
  );
}

Future<bool> showDeleteConfirmDialog(BuildContext context, String what) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Silme Onayı'),
      content: Text('$what silinsin mi?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Vazgeç'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sil', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return result == true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(AssignmentAdapter());
  await Hive.openBox<Product>('products');
  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Assignment>('assignments');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depo Zimmet Takip Sistemi',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF0A2342), 
          onPrimary: Colors.white,
          secondary: Color(0xFFFF9800),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2342), // Lacivert
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A2342), 
          selectedItemColor: Color(0xFFFF9800), 
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
          bodySmall: TextStyle(color: Colors.black, fontSize: 12),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          titleSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _panels = [
    const EmployeePanel(),
    const ProductPanel(),
    const OutputPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _panels[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Çalışan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Ürün',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Çıktı',
          ),
        ],
      ),
    );
  }
}

class EmployeePanel extends StatelessWidget {
  const EmployeePanel({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çalışan Paneli'),
          backgroundColor: Color(0xFF0A2342), 
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.white,
            indicatorColor: Color(0xFFFF9800),
            tabs: [
              Tab(text: 'Çalışanlar'),
              Tab(text: 'Çalışan Ekle'),
              Tab(text: 'Toplu Ekle'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmployeesPage(),
            AddEmployeePage(),
            BulkAddEmployeePage(),
          ],
        ),
      ),
    );
  }
}

class ProductPanel extends StatelessWidget {
  const ProductPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ürün Paneli'),
          backgroundColor: Color(0xFF0A2342), 
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.white,
            indicatorColor: Color(0xFFFF9800),
            tabs: [
              Tab(text: 'Zimmetlenmemiş'),
              Tab(text: 'Zimmetli'),
              Tab(text: 'Ürün Ekle'),
              Tab(text: 'Toplu Ekle'),
              Tab(text: 'Barkod Ara'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UnassignedProductsPage(),
            AssignedProductsPage(),
            AddProductPage(),
            BulkAddProductPage(),
            BarcodeSearchPage(),
          ],
        ),
      ),
    );
  }
}

class OutputPanel extends StatelessWidget {
  const OutputPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çıktı Paneli'),
          backgroundColor: Color(0xFF0A2342), 
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.white,
            indicatorColor: Color(0xFFFF9800),
            tabs: [
              Tab(text: 'Excel Aktar'),
              Tab(text: 'Kılavuz'),
            ],
          ),
        ),
        body: TabBarView(
          children: const [
            ExportExcelPage(),
            HelpPage(),
          ],
        ),
      ),
    );
  }
}


class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});
  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> employees = [];
  late Box<Employee> employeeBox;

  @override
  void initState() {
    super.initState();
    employeeBox = Hive.box<Employee>('employees');
    _loadEmployees();
  }

  void _loadEmployees() {
    setState(() {
      employees = employeeBox.values.toList();
    });
  }

  Future<void> _addEmployee(Employee employee) async {
    await employeeBox.add(employee);
    _loadEmployees();
  }

  Future<void> _deleteEmployee(int i) async {
    final ok = await showDeleteConfirmDialog(context, 'Çalışan');
    if (ok) {
      await employees[i].delete();
      _loadEmployees();
    }
  }

  void _showDetail(int i) {
    final e = employees[i];
    showDetailDialog(context, 'Çalışan Detayı', {
      'Ad': e.name,
      'Soyad': e.surname,
      'Birim': e.department ?? '',
      'Pozisyon': e.position ?? '',
      'E-posta': e.email ?? '',
      'Telefon': e.phone ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = employees.where((e) {
      final q = _searchController.text.toLowerCase();
      return e.name.toLowerCase().contains(q) ||
          e.surname.toLowerCase().contains(q) ||
          (e.department ?? '').toLowerCase().contains(q) ||
          (e.position ?? '').toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışanlar', style: TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)])),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF90A4AE)]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade700,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeePage())),
        tooltip: 'Çalışan Ekle',
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ad, Soyad, Birim veya Pozisyon ile ara',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Henüz çalışan eklenmedi.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final e = filtered[i];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey.shade700,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                '${e.name} ${e.surname}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                '${e.department ?? ''} - ${e.position ?? ''}\n${e.email ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                                    onPressed: () => _showDetail(i),
                                    splashRadius: 24,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEmployee(i),
                                    splashRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});
  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        name: _nameController.text,
        surname: _surnameController.text,
        department: _departmentController.text,
        position: _positionController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      await Hive.box<Employee>('employees').add(employee);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Çalışan Eklendi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ad Soyad: ${_nameController.text} ${_surnameController.text}'),
              Text('Birim: ${_departmentController.text}'),
              Text('Pozisyon: ${_positionController.text}'),
              Text('E-posta: ${_emailController.text}'),
              Text('Telefon: ${_phoneController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); 
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      _nameController.clear();
      _surnameController.clear();
      _departmentController.clear();
      _positionController.clear();
      _emailController.clear();
      _phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışan Ekle'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Çalışan Bilgileri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ad', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Ad giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(labelText: 'Soyad', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Soyad giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(labelText: 'Birim', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Pozisyon', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Çalışanı Kaydet',
                    icon: Icons.save,
                    onPressed: _onSubmit,
                    backgroundColor: Colors.blueGrey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class BulkAddEmployeePage extends StatefulWidget {
  const BulkAddEmployeePage({super.key});
  @override
  State<BulkAddEmployeePage> createState() => _BulkAddEmployeePageState();
}

class _BulkAddEmployeePageState extends State<BulkAddEmployeePage> {
  final List<Map<String, dynamic>> employees = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _addEmployee() {
    if (_formKey.currentState!.validate()) {
      employees.add({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'department': _departmentController.text.trim(),
        'position': _positionController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      setState(() {});
      _nameController.clear();
      _surnameController.clear();
      _departmentController.clear();
      _positionController.clear();
      _emailController.clear();
      _phoneController.clear();
    }
  }

  void _removeEmployee(int index) {
    setState(() {
      employees.removeAt(index);
    });
  }

  void _onSaveAll() async {
    if (employees.isEmpty) return;
    final employeeBox = Hive.box<Employee>('employees');
    for (final emp in employees) {
      final employee = Employee(
        name: emp['name'],
        surname: emp['surname'],
        department: emp['department'],
        position: emp['position'],
        email: emp['email'],
        phone: emp['phone'],
      );
      await employeeBox.add(employee);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Toplu Çalışan Kaydı'),
          ],
        ),
        content: Text('çalışan başarıyla kaydedildi!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    setState(() {
      employees.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Çalışan Yükle'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Çalışan Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Ad', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Ad giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _surnameController,
                          decoration: const InputDecoration(labelText: 'Soyad', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Soyad giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(labelText: 'Birim', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(labelText: 'Pozisyon', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      CustomButton(
                        text: 'Çalışan Ekle',
                        icon: Icons.add,
                        onPressed: _addEmployee,
                        backgroundColor: Colors.blueGrey.shade700,
                        width: 180,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Eklenen Çalışanlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                employees.isEmpty
                    ? const Text('Henüz çalışan eklenmedi.')
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Ad')),
                            DataColumn(label: Text('Soyad')),
                            DataColumn(label: Text('Birim')),
                            DataColumn(label: Text('Pozisyon')),
                            DataColumn(label: Text('E-posta')),
                            DataColumn(label: Text('Telefon')),
                            DataColumn(label: Text('Sil')),
                          ],
                          rows: [
                            for (int i = 0; i < employees.length; i++)
                              DataRow(cells: [
                                DataCell(Text(employees[i]['name'])),
                                DataCell(Text(employees[i]['surname'])),
                                DataCell(Text(employees[i]['department'])),
                                DataCell(Text(employees[i]['position'])),
                                DataCell(Text(employees[i]['email'])),
                                DataCell(Text(employees[i]['phone'])),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeEmployee(i),
                                )),
                              ]),
                          ],
                        ),
                      ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Tümünü Kaydet',
                  icon: Icons.save,
                  onPressed: _onSaveAll,
                  backgroundColor: Colors.green.shade700,
                  width: 200,
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text('Excel/CSV ile Toplu Yükle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, size: 32),
                      const SizedBox(width: 16),
                      const Text('Excel/CSV dosyası seç', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Flexible(
                        child: CustomButton(
                          text: 'Dosya Seç',
                          icon: Icons.file_open,
                          onPressed: () {},
                          width: 120,
                          height: 48,
                          backgroundColor: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AssignPage extends StatefulWidget {
  const AssignPage({super.key});
  @override
  State<AssignPage> createState() => _AssignPageState();
}

class _AssignPageState extends State<AssignPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _shelfController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  List<Assignment> assignments = [];
  late Box<Assignment> assignmentBox;

  @override
  void initState() {
    super.initState();
    assignmentBox = Hive.box<Assignment>('assignments');
    _loadAssignments();
    _dateController.text = _todayString();
  }

  void _loadAssignments() {
    setState(() {
      assignments = assignmentBox.values.toList();
    });
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _addAssignment() async {
    if (_formKey.currentState!.validate()) {
      final assignment = Assignment(
        employeeName: _employeeController.text.trim(),
        productName: _productController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        date: _dateController.text.trim(),
        shelf: _shelfController.text.trim(),
        unit: _unitController.text.trim(),
      );
      await assignmentBox.add(assignment);
      _loadAssignments();
      _employeeController.clear();
      _productController.clear();
      _quantityController.text = '1';
      _dateController.text = _todayString();
      _shelfController.clear();
      _unitController.clear();
    }
  }

  Future<void> _deleteAssignment(int i) async {
    final ok = await showDeleteConfirmDialog(context, 'Zimmet');
    if (ok) {
      await assignments[i].delete();
      _loadAssignments();
    }
  }

  void _showDetail(int i) {
    final a = assignments[i];
    showDetailDialog(context, 'Zimmet Detayı', {
      'Çalışan': a.employeeName,
      'Ürün': a.productName,
      'Adet': a.quantity,
      'Tarih': a.date,
      'Raf': a.shelf ?? '',
      'Birim': a.unit ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zimmetleme'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Zimmet Bilgileri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _employeeController,
                          decoration: const InputDecoration(labelText: 'Çalışan (Ad Soyad)', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Çalışan giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _productController,
                          decoration: const InputDecoration(labelText: 'Ürün (Ad/Marka)', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Ürün giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Adet', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) return 'Geçerli bir adet giriniz';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Verilen Tarih (YYYY-AA-GG)', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _shelfController,
                          decoration: const InputDecoration(labelText: 'Raf', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(labelText: 'Birim', border: OutlineInputBorder()),
                        ),
                      ),
                      CustomButton(
                        text: 'Zimmetle',
                        icon: Icons.assignment_turned_in,
                        onPressed: _addAssignment,
                        backgroundColor: Colors.blueGrey.shade700,
                        width: 140,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Zimmetlenenler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Çalışan')),
                      DataColumn(label: Text('Ürün')),
                      DataColumn(label: Text('Adet')),
                      DataColumn(label: Text('Tarih')),
                      DataColumn(label: Text('Raf')),
                      DataColumn(label: Text('Birim')),
                      DataColumn(label: Text('İşlem')),
                    ],
                    rows: [
                      for (int i = 0; i < assignments.length; i++)
                        DataRow(cells: [
                          DataCell(Text(assignments[i].employeeName)),
                          DataCell(Text(assignments[i].productName)),
                          DataCell(Text(assignments[i].quantity.toString())),
                          DataCell(Text(assignments[i].date)),
                          DataCell(Text(assignments[i].shelf ?? '')),
                          DataCell(Text(assignments[i].unit ?? '')),
                          DataCell(Row(
                            children: [
                              CustomButton(
                                text: 'Sil',
                                icon: Icons.delete,
                                onPressed: () => _deleteAssignment(i),
                                backgroundColor: const Color.fromARGB(255, 221, 46, 46),
                                width: 80,
                              ),
                              const SizedBox(width: 8),
                              CustomButton(
                                text: 'Detay',
                                icon: Icons.info_outline,
                                onPressed: () => _showDetail(i),
                                backgroundColor: const Color.fromARGB(255, 124, 156, 172),
                                width: 90,
                              ),
                            ],
                          )),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class UnassignedProductsPage extends StatefulWidget {
  const UnassignedProductsPage({super.key});
  @override
  State<UnassignedProductsPage> createState() => _UnassignedProductsPageState();
}

class _UnassignedProductsPageState extends State<UnassignedProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  late Box<Product> productBox;

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zimmetlenmemiş Ürünler', style: TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)])),
        backgroundColor: const Color.fromARGB(255, 68, 90, 100),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF90A4AE)]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade700,
        child: const Icon(Icons.add_box, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
        tooltip: 'Ürün Ekle',
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Etiket No, Ürün Türü veya Ürün Adı ile ara',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: productBox.listenable(),
                builder: (context, Box<Product> box, _) {
                  final q = _searchController.text.toLowerCase();
                  final filtered = box.values.where((p) =>
                    p.isAssigned == false && (
                      p.id.toLowerCase().contains(q) ||
                      p.type.toLowerCase().contains(q) ||
                      p.name.toLowerCase().contains(q)
                    )
                  ).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Henüz zimmetlenmemiş ürün yok.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade700,
                              child: const Icon(Icons.inventory, color: Colors.white),
                            ),
                            title: Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              'Etiket: ${p.id}\nTür: ${p.type}\nStok: ${p.stock}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.assignment_turned_in, color: Colors.green),
                                  onPressed: () => _showAssignDialog(p),
                                  splashRadius: 24,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                                  onPressed: () => _showDetail(p),
                                  splashRadius: 24,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(p),
                                  splashRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final ok = await showDeleteConfirmDialog(context, 'Ürün');
    if (ok) {
      await product.delete();
    }
  }

  void _showDetail(Product product) {
    showDetailDialog(context, 'Ürün Detayı', {
      'ID': product.id,
      'Ad': product.name,
      'Marka': product.brand,
      'Tür': product.type,
      'Stok': product.stock,
      'Alınan': product.received,
      'Tarih': product.date,
      'Raf': product.shelf ?? '',
      'Açıklama': product.desc ?? '',
      'IMEI': product.imei ?? '',
      'Seri No': product.serialNo ?? '',
    });
  }

  void _showAssignDialog(Product product) async {
    final employeesBox = Hive.box<Employee>('employees');
    final employees = employeesBox.values.toList();
    Employee? selectedEmployee;
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final TextEditingController unitController = TextEditingController(text: product.unit ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Zimmetle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ürün: ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Seri No: ${product.id}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              DropdownButtonFormField<Employee>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Çalışan Seç', border: OutlineInputBorder()),
                items: employees.map((e) => DropdownMenuItem<Employee>(
                  value: e,
                  child: Text('${e.name} ${e.surname}'),
                )).toList(),
                onChanged: (e) => selectedEmployee = e,
                validator: (v) => v == null ? 'Çalışan seçiniz' : null,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Adet', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Tarih (YYYY-AA-GG)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Verilen Birim', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
              final date = dateController.text.trim();
              final unit = unitController.text.trim();
              if (selectedEmployee != null && quantity > 0) {
                product.isAssigned = true;
                product.assignedTo = '${selectedEmployee!.name} ${selectedEmployee!.surname}';
                await product.save();
                final assignment = Assignment(
                  employeeName: '${selectedEmployee!.name} ${selectedEmployee!.surname}',
                  productName: product.name,
                  quantity: quantity,
                  date: date,
                  shelf: product.shelf,
                  unit: unit,
                );
                await Hive.box<Assignment>('assignments').add(assignment);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Zimmetle'),
          ),
        ],
      ),
    );
  }
}
class AssignedProductsPage extends StatefulWidget {
  const AssignedProductsPage({super.key});
  @override
  State<AssignedProductsPage> createState() => _AssignedProductsPageState();
}

class _AssignedProductsPageState extends State<AssignedProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> assignedProducts = [];
  late Box<Product> productBox;

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
    _loadAssignedProducts();
  }

  void _loadAssignedProducts() {
    setState(() {
      assignedProducts = productBox.values.where((p) => p.isAssigned).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = assignedProducts.where((p) {
      final q = _searchController.text.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.assignedTo ?? '').toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zimmetlenmiş Ürünler', style: TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)])),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF90A4AE)]),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ara (Ürün, Çalışan, ID)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Product>('products').listenable(),
                builder: (context, Box<Product> box, _) {
                  final assignedProducts = box.values.where((p) => p.isAssigned).toList();
                  final filtered = assignedProducts.where((p) {
                    final q = _searchController.text.toLowerCase();
                    return p.name.toLowerCase().contains(q) ||
                        (p.assignedTo ?? '').toLowerCase().contains(q) ||
                        p.id.toLowerCase().contains(q);
                  }).toList();
                  return filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Henüz zimmetlenmiş ürün yok.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueGrey.shade400,
                                    child: const Icon(Icons.assignment_turned_in, color: Colors.white),
                                  ),
                                  title: Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    'ID: ${p.id}\nZimmetli: ${p.assignedTo ?? ''}\nTarih: ${p.date}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.assignment_return, color: Colors.green),
                                        tooltip: 'Teslim Al',
                                        onPressed: () async {
                                          p.isAssigned = false;
                                          p.assignedTo = '';
                                          await p.save();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${p.name} depoya teslim alındı!')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                                        onPressed: () => showDetailDialog(context, 'Zimmetli Ürün Detayı', {
                                          'ID': p.id,
                                          'Ad': p.name,
                                          'Marka': p.brand,
                                          'Tür': p.type,
                                          'Zimmetli Kişi': p.assignedTo ?? '',
                                          'Zimmet Tarihi': p.date,
                                          'IMEI': p.imei ?? '',
                                          'Seri No': p.serialNo ?? '',
                                        }),
                                        splashRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class BulkAddProductPage extends StatefulWidget {
  const BulkAddProductPage({super.key});
  @override
  State<BulkAddProductPage> createState() => _BulkAddProductPageState();
}

class _BulkAddProductPageState extends State<BulkAddProductPage> {
  final List<Map<String, dynamic>> products = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _shelfController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final productBox = Hive.box<Product>('products');
      final brand = _brandController.text.trim();
      final type = _typeController.text.trim();
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final key = (brand + type).toLowerCase();
      final alreadyAddedCount = products.where((p) => (p['brand'] + p['type']).toLowerCase() == key).length;
      for (int i = 0; i < quantity; i++) {

        final id = generateProductId(
          brand,
          type,
          productBox,
          extraCount: alreadyAddedCount + i,
          pendingProducts: products,
        );
        products.add({
          'id': id,
          'barcode': id,
          'name': _nameController.text.trim(),
          'brand': brand,
          'type': type,
          'shelf': _shelfController.text.trim(),
          'unit': _unitController.text.trim(),
          'desc': _descController.text.trim(),
          'imei': _imeiController.text.trim().isEmpty ? null : _imeiController.text.trim(),
          'serialNo': _serialNoController.text.trim().isEmpty ? null : _serialNoController.text.trim(),
        });
      }
      setState(() {});
      _nameController.clear();
      _brandController.clear();
      _typeController.clear();
      _quantityController.text = '1';
      _shelfController.clear();
      _unitController.clear();
      _descController.clear();
      _imeiController.clear();
      _serialNoController.clear();
    }
  }

  void _removeProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void _onSaveAll() async {
    if (products.isEmpty) return;
    final productBox = Hive.box<Product>('products');
    for (final prod in products) {
      final product = Product(
        id: prod['id'],
        name: prod['name'],
        brand: prod['brand'],
        type: prod['type'],
        shelf: prod['shelf'],
        unit: prod['unit'],
        desc: prod['desc'],
        stock: 0,
        received: 0,
        date: DateTime.now().toString().substring(0, 10),
        isAssigned: false,
        imei: prod['imei'],
        serialNo: prod['serialNo'],
      );
      await productBox.add(product);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Toplu Ürün Kaydı'),
          ],
        ),
        content: Text('${products.length} ürün başarıyla kaydedildi!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    setState(() {
      products.clear();
    });
  }

  Future<void> _onExcelImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hata'),
            content: const Text('Dosya okunamadı. Lütfen farklı bir dosya seçin.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))],
          ),
        );
        return;
      }
      final fileBytes = file.bytes!;
      final excel = ex.Excel.decodeBytes(fileBytes);
      final productBox = Hive.box<Product>('products');
      int imported = 0;
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        final headers = sheet.rows.first.map((e) => (e?.value ?? '').toString().trim()).toList();
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          String getCol(String colName) {
            final idx = headers.indexOf(colName);
            if (idx == -1 || idx >= row.length) return '';
            return (row[idx]?.value ?? '').toString().trim();
          }
          final product = Product(
            id: getCol('ETİKET NO'),
            name: getCol('ÜRÜN ADI'),
            brand: getCol('ÜRÜN ANA GR'),
            type: getCol('ÜRÜN TÜRÜ'),
            shelf: '',
            unit: '',
            desc: getCol('AÇIKLAMA'),
            stock: int.tryParse(getCol('MEVCUT ADET')) ?? 0,
            received: int.tryParse(getCol('ALINAN ADET')) ?? 0,
            date: getCol('ALINAN TARİH'),
            isAssigned: false,
            imei: getCol('İmal'),
            serialNo: getCol('Seri No'),
          );
          await productBox.add(product);
          imported++;
        }
      }
      // Başarı mesajı
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excel Aktarıldı'),
          content: Text('$imported ürün başarıyla eklendi!'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hata'),
          content: Text('Excel aktarımında hata oluştu: $e'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Ürün Yükle'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ürün Bilgilerini Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Ürün Adı', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Ürün adı giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(labelText: 'Marka', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Marka giriniz' : null,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(labelText: 'Tür', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Tür giriniz' : null,

                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Adet', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) return 'Geçerli bir adet giriniz';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _shelfController,
                          decoration: const InputDecoration(labelText: 'Raf', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(labelText: 'Birim', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _imeiController,
                          decoration: const InputDecoration(labelText: 'IMEI', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _serialNoController,
                          decoration: const InputDecoration(labelText: 'Seri No', border: OutlineInputBorder()),
                        ),
                      ),
                      CustomButton(
                        text: 'Ürün Ekle',
                        icon: Icons.add,
                        onPressed: _addProduct,
                        backgroundColor: Colors.blueGrey.shade700,
                        width: 180,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Eklenen Ürünler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                products.isEmpty
                    ? const Text('Henüz ürün eklenmedi.')
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Barkod')),
                              DataColumn(label: Text('Adı')),
                              DataColumn(label: Text('Marka')),
                              DataColumn(label: Text('Tür')),
                              DataColumn(label: Text('Raf')),
                              DataColumn(label: Text('Birim')),
                              DataColumn(label: Text('Açıklama')),
                              DataColumn(label: Text('IMEI')),
                              DataColumn(label: Text('Seri No')),
                              DataColumn(label: Text('Sil')),
                            ],
                            rows: [
                              for (int i = 0; i < products.length; i++)
                                DataRow(cells: [
                                  DataCell(Text(products[i]['id'])),
                                  DataCell(Text(products[i]['barcode'])),
                                  DataCell(Text(products[i]['name'])),
                                  DataCell(Text(products[i]['brand'])),
                                  DataCell(Text(products[i]['type'])),
                                  DataCell(Text(products[i]['shelf'])),
                                  DataCell(Text(products[i]['unit'])),
                                  DataCell(Text(products[i]['desc'])),
                                  DataCell(Text(products[i]['imei'] ?? '')),
                                  DataCell(Text(products[i]['serialNo'] ?? '')),
                                  DataCell(IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeProduct(i),
                                  )),
                                ]),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Tümünü Kaydet',
                  icon: Icons.save,
                  onPressed: _onSaveAll,
                  backgroundColor: Colors.green.shade700,
                  width: 200,
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text('Excel/CSV ile Toplu Yükle ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, size: 32),
                      const SizedBox(width: 16),
                      const Text('Excel/CSV dosyası seç', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Flexible(
                        child: CustomButton(
                          text: 'Dosya Seç',
                          icon: Icons.file_open,
                          onPressed: _onExcelImport,
                          width: 120,
                          height: 48,
                          backgroundColor: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _shelfController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();

  List<Map<String, dynamic>> generatedProducts = [];

  void _generateProducts() {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final type = _typeController.text.trim();
    final shelf = _shelfController.text.trim();
    final unit = _unitController.text.trim();
    final desc = _descController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final now = DateTime.now();
    generatedProducts = List.generate(quantity, (i) {
      final id = generateProductId(brand, type, Hive.box<Product>('products'));
      final barcode = id;
      return {
        'id': id,
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'type': type,
        'shelf': shelf,
        'unit': unit,
        'desc': desc,
        'imei': _imeiController.text.trim().isEmpty ? null : _imeiController.text.trim(),
        'serialNo': _serialNoController.text.trim().isEmpty ? null : _serialNoController.text.trim(),
      };
    });
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final productBox = Hive.box<Product>('products');
      final brand = _brandController.text.trim();
      final type = _typeController.text.trim();
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      for (int i = 0; i < quantity; i++) {
        final id = generateProductId(brand, type, productBox);
        final product = Product(
          id: id,
          name: _nameController.text.trim(),
          brand: brand,
          type: type,
          stock: 1,
          received: 1,
          date: DateTime.now().toString().substring(0, 10),
          shelf: _shelfController.text.trim(),
          unit: _unitController.text.trim(),
          desc: _descController.text.trim(),
          isAssigned: false,
          imei: _imeiController.text.trim().isEmpty ? null : _imeiController.text.trim(),
          serialNo: _serialNoController.text.trim().isEmpty ? null : _serialNoController.text.trim(),
        );
        await productBox.add(product);
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ürün(ler) Eklendi'),
          content: Text('Ürün(ler) başarıyla eklendi ve zimmetlenmemiş ürünler listesine aktarıldı.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      _nameController.clear();
      _brandController.clear();
      _typeController.clear();
      _quantityController.text = '1';
      _shelfController.clear();
      _unitController.clear();
      _descController.clear();
      _imeiController.clear();
      _serialNoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Ekle'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ürün Bilgileri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ürün Adı', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Ürün adı giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: 'Marka', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Marka giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(labelText: 'Tür', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Tür giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Adet', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Geçerli bir adet giriniz';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shelfController,
                    decoration: const InputDecoration(labelText: 'Raf', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Birim', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imeiController,
                    decoration: const InputDecoration(labelText: 'IMEI', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serialNoController,
                    decoration: const InputDecoration(labelText: 'Seri No', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Ürünleri Kaydet',
                    icon: Icons.save,
                    onPressed: _onSubmit,
                    backgroundColor: Colors.blueGrey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class BarcodeSearchPage extends StatefulWidget {
  const BarcodeSearchPage({super.key});
  @override
  State<BarcodeSearchPage> createState() => _BarcodeSearchPageState();
}

class _BarcodeSearchPageState extends State<BarcodeSearchPage> {
  final TextEditingController _barcodeController = TextEditingController();
  Product? foundProduct;

  void _searchBarcode() {
    final id = _barcodeController.text.trim();
    final box = Hive.box<Product>('products');
    Product? product;
    final matches = box.values.where((p) => p.id == id);
    if (matches.isNotEmpty) {
      product = matches.first;
    } else {
      product = null;
    }
    setState(() {
      foundProduct = product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod ile Ara'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              // Barkod Ara sayfası arama kutusu ve butonlar
              const Text('Barkod Numarası veya ID Girin/Okutun:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _barcodeController,
                style: const TextStyle(fontSize: 22, height: 1.8),
                decoration: const InputDecoration(
                  labelText: 'Barkod/ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                  contentPadding: EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                ),
                onSubmitted: (_) => _searchBarcode(),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    text: 'Ara',
                    icon: Icons.search,
                    onPressed: _searchBarcode,
                    height: 48,
                    backgroundColor: Colors.blueGrey.shade700,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Kamera ile Tara',
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarcodeScannerPage(
                            onScanned: (code) {
                              _barcodeController.text = code;
                              _searchBarcode();
                            },
                          ),
                        ),
                      );
                    },
                    height: 48,
                    backgroundColor: Colors.orange.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (foundProduct != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ürün: ${foundProduct!.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Marka: ${foundProduct!.brand}'),
                        Text('Tür: ${foundProduct!.type}'),
                        Text('ID: ${foundProduct!.id}'),
                        Text('IMEI: ${foundProduct!.imei ?? ''}'),
                        Text('Seri No: ${foundProduct!.serialNo ?? ''}'),
                        const SizedBox(height: 16),
                        Center(
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: foundProduct!.id,
                            width: 200,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_barcodeController.text.isNotEmpty)
                const Text('Ürün bulunamadı.', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodeScannerPage extends StatelessWidget {
  final void Function(String) onScanned;
  const BarcodeScannerPage({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barkod Tara')),
      body: ms.MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              onScanned(code);
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}

class ExportExcelPage extends StatelessWidget {
  const ExportExcelPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Excel'e Aktar"),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Verileri Excel'e Aktar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Ürün, çalışan veya zimmet verilerini Excel dosyasından toplu olarak içe aktarabilirsiniz.'),
              const SizedBox(height: 32),
              CustomButton(
                text: "Excel'den Toplu Aktar",
                icon: Icons.file_upload,
                onPressed: () => importFromExcel(context),
                backgroundColor: Colors.green.shade700,
                width: double.infinity,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Verileri Excel Olarak Dışa Aktar",
                icon: Icons.file_download,
                onPressed: () async {
                  final products = Hive.box<Product>('products').values.toList();
                  final employees = Hive.box<Employee>('employees').values.toList();
                  await exportProductsToExcel(products, context);
                  await exportEmployeesToExcel(employees, context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Excel dosyaları oluşturuldu ve kaydedildi!')),
                  );
                },
                backgroundColor: Colors.blue.shade700,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Kılavuzu'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text('Kullanım Kılavuzu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('• Ana panelden istediğiniz işlemi seçebilirsiniz.'),
            Text('• Ürün ve çalışan ekleme işlemlerini ilgili menülerden yapabilirsiniz.'),
            Text('• Zimmetleme işlemi için önce ürün ve çalışan eklenmiş olmalı.'),
            Text('• Barkod ile arama ve yazdırma işlemleri için barkod numarasını girmeniz yeterli.'),
            Text('• Toplu yükleme ve Excel aktarım işlemleri için ilgili butonları kullanabilirsiniz.'),
            SizedBox(height: 24),
            Text('Herhangi bir sorunda IT birimi ile iletişime geçiniz.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final String title;
  const _EmptyPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '$title sayfası yakında burada olacak.',
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}

String generateProductId(String brand, String type, Box<Product> productBox, {int extraCount = 0, List<Map<String, dynamic>>? pendingProducts}) {
  final allProducts = productBox.values.toList();
  final key = (brand.trim() + type.trim()).toLowerCase();
  final anaKodMap = <String, String>{};
  int anaKodCounter = 1;
  for (final p in allProducts) {
    final k = (p.brand.trim() + p.type.trim()).toLowerCase();
    if (!anaKodMap.containsKey(k)) {
      anaKodMap[k] = 'Yurt${anaKodCounter.toString().padLeft(4, '0')}';
      anaKodCounter++;
    }
  }
  
  if (pendingProducts != null) {
    for (final p in pendingProducts) {
      final k = ((p['brand'] ?? '').toString().trim() + (p['type'] ?? '').toString().trim()).toLowerCase();
      if (k.isNotEmpty && !anaKodMap.containsKey(k)) {
        anaKodMap[k] = 'Yurt${anaKodCounter.toString().padLeft(4, '0')}';
        anaKodCounter++;
      }
    }
  }
  if (!anaKodMap.containsKey(key)) {
    anaKodMap[key] = 'Yurt${anaKodCounter.toString().padLeft(4, '0')}';
  }
  final anaKod = anaKodMap[key]!;
  final anaKodluUrunler = [
    ...allProducts.where((p) => (p.brand.trim() + p.type.trim()).toLowerCase() == key),
    if (pendingProducts != null)
      ...pendingProducts.where((p) => ((p['brand'] ?? '').toString().trim() + (p['type'] ?? '').toString().trim()).toLowerCase() == key),
  ];
  final itNo = anaKodluUrunler.length + 1 + extraCount;
  final itKod = 'IT${itNo.toString().padLeft(3, '0')}';
  return '$anaKod-$itKod';
}

Future<void> importFromExcel(BuildContext context) async {
  final typeGroup = XTypeGroup(label: 'excel', extensions: ['xlsx', 'xls']);
  final file = await openFile(acceptedTypeGroups: [typeGroup]);
  if (file == null) return;
  final fileBytes = await file.readAsBytes();
  if (fileBytes.isEmpty) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hata'),
        content: const Text('Dosya okunamadı. Lütfen farklı bir dosya seçin.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))],
      ),
    );
    return;
  }
  final excel = ex.Excel.decodeBytes(fileBytes);

  final productBox = Hive.box<Product>('products');
  final employeeBox = Hive.box<Employee>('employees');
  final assignmentBox = Hive.box<Assignment>('assignments');

  int productCount = 0, employeeCount = 0, assignmentCount = 0, updatedProductCount = 0, updatedEmployeeCount = 0;

  for (final table in excel.tables.keys) {
    final sheet = excel.tables[table]!;
    final headers = sheet.rows.first.map((e) => (e?.value ?? '').toString().trim()).toList();

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      String getCol(String colName) {
        final idx = headers.indexOf(colName);
        if (idx == -1 || idx >= row.length) return '';
        return (row[idx]?.value ?? '').toString().trim();
      }

      // Ürün işlemleri (ETİKET NO ile kontrol)
      final etiketNo = getCol('ETİKET NO');
      if (etiketNo.isEmpty) continue;
      final existingProduct = productBox.values.where((p) => p.id == etiketNo).isEmpty
          ? null
          : productBox.values.firstWhere((p) => p.id == etiketNo);
      final productData = Product(
        id: etiketNo,
        name: getCol('ÜRÜN ADI'),
        brand: getCol('ÜRÜN ANA GRUBU'),
        type: getCol('ÜRÜN TÜRÜ'),
        shelf: getCol('RAF NO'),
        unit: getCol('Verilen Birim'),
        desc: getCol('AÇIKLAMA'),
        stock: int.tryParse(getCol('MEVCUT ADET')) ?? 0,
        received: int.tryParse(getCol('ALINAN ADET')) ?? 0,
        date: getCol('ALINAN TARİH'),
        isAssigned: getCol('Adı Soyadı').isNotEmpty,
        imei: getCol('imei'),
        serialNo: getCol('Seri No').isNotEmpty ? getCol('Seri No') : getCol('Model No'),
        assignedTo: getCol('Adı Soyadı').isNotEmpty ? getCol('Adı Soyadı') : null,
      );
      if (existingProduct != null) {
        // Güncelle
        existingProduct.name = productData.name;
        existingProduct.brand = productData.brand;
        existingProduct.type = productData.type;
        existingProduct.shelf = productData.shelf;
        existingProduct.unit = productData.unit;
        existingProduct.desc = productData.desc;
        existingProduct.stock = productData.stock;
        existingProduct.received = productData.received;
        existingProduct.date = productData.date;
        existingProduct.isAssigned = productData.isAssigned;
        existingProduct.imei = productData.imei;
        existingProduct.serialNo = productData.serialNo;
        existingProduct.assignedTo = productData.assignedTo;
        await existingProduct.save();
        updatedProductCount++;
      } else {
        await productBox.add(productData);
        productCount++;
      }

      // Çalışan işlemleri (Adı Soyadı ile kontrol)
      final adSoyad = getCol('Adı Soyadı');
      if (adSoyad.isNotEmpty) {
        final names = adSoyad.split(' ');
        final name = names.first;
        final surname = names.length > 1 ? names.sublist(1).join(' ') : '';
        final existingEmployee = employeeBox.values.where((e) => e.name == name && e.surname == surname).isEmpty
            ? null
            : employeeBox.values.firstWhere((e) => e.name == name && e.surname == surname);
        if (existingEmployee != null) {
          // Güncelle (ekstra alanlar varsa ekle)
          updatedEmployeeCount++;
        } else {
          final employee = Employee(
            name: name,
            surname: surname,
          );
          await employeeBox.add(employee);
          employeeCount++;
        }
      }

      // Zimmet işlemleri
      // Önce eski zimmetleri kaldır (aynı ürün için)
      final existingAssignments = assignmentBox.values.where((a) => a.productName == getCol('ÜRÜN ADI')).toList();
      for (final a in existingAssignments) {
        await a.delete();
      }
      if (getCol('Adı Soyadı').isNotEmpty) {
        // Zimmet ekle
        final assignment = Assignment(
          employeeName: getCol('Adı Soyadı'),
          productName: getCol('ÜRÜN ADI'),
          quantity: int.tryParse(getCol('Verilen Adet')) ?? 1,
          date: getCol('Verilen Tarih'),
          shelf: getCol('RAF NO'),
          unit: getCol('Verilen Birim'),
        );
        await assignmentBox.add(assignment);
        assignmentCount++;
      }
    }
  }
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excel Aktarıldı'),
      content: Text('Yeni Ürün: $productCount\nGüncellenen Ürün: $updatedProductCount\nYeni Çalışan: $employeeCount\nGüncellenen Çalışan: $updatedEmployeeCount\nZimmet: $assignmentCount başarıyla aktarıldı!'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))],
    ),
  );
}

Future<void> exportProductsToExcel(List<Product> products, BuildContext context) async {
  var excel = ex.Excel.createExcel();
  var sheet = excel['Sheet1'];
  // Sütun başlıkları birebir ekran görüntüsündeki gibi
  sheet.appendRow([
    'ÜRÜN TÜRÜ',
    'ÜRÜN ANA GRUBU',
    'ETİKET NO',
    'ÜRÜN ADI',
    'Seri No',
    'imei',
    'Model No',
    'ALINAN TARİH',
    'ALINAN ADET',
    'MEVCUT ADET',
    'AÇIKLAMA',
    'Verilen Adet',
    'Verilen Tarih',
    'Verilen Birim',
    'Adı Soyadı',
    'İade Tarih',
    'İade Açıklama',
    'RAF NO',
  ]);
  for (final p in products) {
    sheet.appendRow([
      p.type,
      p.brand,
      p.id,
      p.name,
      p.serialNo ?? '',
      p.imei ?? '',
      '', // Model No
      p.date ?? '',
      p.received.toString(),
      p.stock.toString(),
      p.desc ?? '',
      '', // Verilen Adet
      '', // Verilen Tarih
      p.unit ?? '',
      p.assignedTo ?? '',
      '', // İade Tarih
      '', // İade Açıklama
      p.shelf ?? '',
    ]);
  }
  final fileBytes = excel.encode();
  final dir = await getExternalStorageDirectory();
  final filePath = '${dir!.path}/urunler_export.xlsx';
  final file = File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes!);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Başarılı'),
      content: Text('Ürünler Excel dosyası kaydedildi:\n$filePath'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            Share.shareXFiles([XFile(filePath)], text: 'Ürünler Excel dosyam');
          },
          child: const Text('Paylaş'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}

Future<void> exportEmployeesToExcel(List<Employee> employees, BuildContext context) async {
  var excel = ex.Excel.createExcel();
  var sheet = excel['Sheet1'];
  sheet.appendRow([
    'Adı Soyadı', 'Verilen Birim', 'Verilen Tarih', 'İade Tarih', 'İade Açıklama', 'RAF NO',
  ]);
  for (final e in employees) {
    sheet.appendRow([
      '${e.name} ${e.surname}', '', '', '', '', '',
    ]);
  }
  final fileBytes = excel.encode();
  final dir = await getExternalStorageDirectory();
  final filePath = '${dir!.path}/calisanlar_export.xlsx';
  final file = File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes!);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Başarılı'),
      content: Text('Çalışanlar Excel dosyası kaydedildi:\n$filePath'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            Share.shareXFiles([XFile(filePath)], text: 'Çalışanlar Excel dosyam');
          },
          child: const Text('Paylaş'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}



