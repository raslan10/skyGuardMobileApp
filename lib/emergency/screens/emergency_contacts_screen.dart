import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/emergency/services/emergency_storage_service.dart';
import 'package:skyguardmobileapp/emergency/models/emergency_contact.dart';

class EmergencyContactsScreen extends StatefulWidget {
  static const String routeName = "emergency_contacts";

  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyStorageService _storageService = EmergencyStorageService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ✨ متغير جديد لحفظ صلة القرابة المختار
  String _selectedRelation = "Father";

  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final savedContacts = await _storageService.getContacts();
      setState(() {
        _contacts = savedContacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ➕ دالة إضافة فرد عائلة جديد متوافقة مع الـ id والـ relation والـ Service عندك
  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;

    // 🧠 توليد ID تلقائي بناءً على الوقت الحالي لتفادي إيرور الـ id
    final int uniqueId = DateTime.now().millisecondsSinceEpoch;

    final newContact = EmergencyContact(
      id: uniqueId, // ✨ تمرير الـ id المطلوب
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relation: _selectedRelation, // ✨ تمرير الـ relation المطلوب
    );

    // ✨ استدعاء الدالة الصح المتوقع وجودها في الـ Service عندك (إضافة للـ List الحالية وحفظها)
    _contacts.add(newContact);
    await _storageService.saveContacts(_contacts); // غالباً اسمها saveContacts وبتاخد الـ List كاملة عندك

    _nameController.clear();
    _phoneController.clear();

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.success(context, 'Family contact added successfully!');
    _loadContacts();
  }

  // ❌ دالة حذف فرد عائلة متوافقة مع الـ Service عندك
  Future<void> _deleteContact(EmergencyContact contact) async {
    _contacts.removeWhere((element) => element.id == contact.id);
    await _storageService.saveContacts(_contacts); // تحديث الحفظ بعد الحذف

    if (!mounted) return;
    AppSnackbar.info(context, 'Contact removed');
    _loadContacts();
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // لاستخدام الـ Dropdown جوه الدايلوج بسلاسة
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Add Family Member 👨‍👩‍👧‍👦",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF014F6E)),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Member Name",
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF007BA7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF007BA7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 12),
                // ✨ Dropdown لاختيار الـ Relation المطلوب من الموديل
                DropdownButtonFormField<String>(
                  value: _selectedRelation,
                  decoration: InputDecoration(
                    labelText: "Relation",
                    prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF007BA7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Father", child: Text("Father")),
                    DropdownMenuItem(value: "Mother", child: Text("Mother")),
                    DropdownMenuItem(value: "Brother", child: Text("Brother")),
                    DropdownMenuItem(value: "Sister", child: Text("Sister")),
                    DropdownMenuItem(value: "Spouse", child: Text("Spouse")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        _selectedRelation = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BA7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _addContact,
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Family Contacts", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF007BA7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF007BA7),
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Member", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.family_restroom, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No Family Contacts Registered Yet",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                "Add your family contacts below so SkyGuard can automatically alert them during accidents or emergency SOS triggers.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEAF7FB),
                child: Text(
                  contact.relation[0], // أول حرف من صلة القرابة كـ Icon
                  style: const TextStyle(color: Color(0xFF007BA7), fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(contact.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text("${contact.relation} • ${contact.phone}", style: GoogleFonts.poppins()),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteContact(contact),
              ),
            ),
          );
        },
      ),
    );
  }
}