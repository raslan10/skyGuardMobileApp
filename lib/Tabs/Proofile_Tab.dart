import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/Login_screen.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/models/profile_model.dart';
import 'package:skyguardmobileapp/services/auth_service.dart';
import 'package:skyguardmobileapp/services/profile_service.dart';
import '../profile/settings_screen.dart';
import 'package:skyguardmobileapp/emergency/screens/emergency_contacts_screen.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ProfileService profileService = ProfileService();
  final AuthService authService = AuthService();

  bool isLoading = true;
  ProfileModel? profile;

  // ✨ متغير لحفظ الصورة الجديدة محلياً لمحاكاة التغيير في الواجهة
  String mockSelectedImage = '';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await profileService.getProfile();
      if (!mounted) return;
      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.handle(e))),
      );
    }
  }

  // 📝 دايلوج اختيار الصورة (كاميرا أو معرض الصور)
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF007BA7)),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
              onTap: () {
                setState(() {
                  // محاكاة وضع صورة ستوديو portrait moody ونظيفة للمناقشة
                  mockSelectedImage = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=250&auto=format&fit=crop";
                });
                Navigator.pop(context);
                AppSnackbar.success(context, "Profile picture updated from gallery! 📸");
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF007BA7)),
              title: Text('Take a New Photo', style: GoogleFonts.poppins()),
              onTap: () {
                setState(() {
                  mockSelectedImage = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop";
                });
                Navigator.pop(context);
                AppSnackbar.success(context, "Profile picture updated from camera! ⚡");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Profile Info", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: "Full Name", labelStyle: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number", labelStyle: GoogleFonts.poppins()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BA7)),
            onPressed: () {
              setState(() {
                if (profile != null) {
                  profile = ProfileModel(
                    name: nameCtrl.text.trim(),
                    email: profile!.email,
                    phone: phoneCtrl.text.trim(),
                    role: profile!.role,
                    profileImage: mockSelectedImage.isNotEmpty ? mockSelectedImage : profile!.profileImage,
                  );
                }
              });
              Navigator.pop(context);
              AppSnackbar.success(context, "Profile updated successfully!");
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?.name.isNotEmpty == true ? profile!.name : 'User Name';
    final email = profile?.email.isNotEmpty == true ? profile!.email : '—';
    final phone = profile?.phone.isNotEmpty == true ? profile!.phone : 'Not added';
    final role = profile?.role.isNotEmpty == true ? profile!.role : 'user';

    // استخدام الصورة الجديدة لو تم اختيارها، غير كدة الصورة القديمة
    final image = mockSelectedImage.isNotEmpty ? mockSelectedImage : (profile?.profileImage ?? '');

    final bool isUserDriver = role.toLowerCase() != 'admin';

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              _profileHeader(
                name: name,
                email: email,
                image: image,
                onEditTap: () => _showEditProfileDialog(name, phone == 'Not added' ? '' : phone),
                onAvatarTap: _showImagePickerOptions,
              ),
              const SizedBox(height: 20),

              _infoCard(Icons.person, "Name", name),
              _infoCard(Icons.email, "Email", email),

              // ✨ التعديل السحري: عرض الـ Role بشكل احترافي وديناميكي متناسق مع شاشة اللوجين
              _infoCard(
                  Icons.badge,
                  "Role",
                  role.toLowerCase() == 'admin' ? 'Supervisor / Admin' : 'Driver / User'
              ),

              _infoCard(Icons.phone, "Phone", phone),

              const SizedBox(height: 24),

              if (isUserDriver) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF7FB),
                      foregroundColor: const Color(0xFF007BA7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF007BA7), width: 1.2),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
                      );
                    },
                    icon: const Icon(Icons.family_restroom),
                    label: Text("Manage Family Contacts", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BA7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    if (!mounted) return;
                    fetchProfile();
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: Text("App Settings", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  label: Text("Logout Account", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader({
    required String name,
    required String email,
    required String image,
    required VoidCallback onEditTap,
    required VoidCallback onAvatarTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFEAF7FB),
                  backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                  child: image.isEmpty ? const Icon(Icons.person, size: 34, color: Color(0xFF007BA7)) : null,
                ),
                const CircleAvatar(
                  radius: 11,
                  backgroundColor: Color(0xFF007BA7),
                  child: Icon(Icons.camera_alt, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Color(0xFF007BA7), size: 28),
            onPressed: onEditTap,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF7FB),
          child: Icon(icon, color: const Color(0xFF007BA7)),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }
}