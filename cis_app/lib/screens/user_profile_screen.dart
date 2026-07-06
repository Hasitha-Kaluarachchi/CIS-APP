import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/network_profile_avatar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isUploading = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getClientProfile();
    if (!mounted) return;
    setState(() {
      _profile = data;
      _isLoading = false;
      _usernameController.text = (data?['username'] ?? '').toString();
      _emailController.text = (data?['email'] ?? '').toString();
      _phoneController.text = (data?['phone'] ?? '').toString();
      _addressController.text = (data?['address'] ?? '').toString();
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    setState(() => _isUploading = true);
    final response = await ApiService.uploadProfilePicture(file: image, role: 'client');
    if (!mounted) return;
    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'Upload completed')),
    );
    if (response['success'] == true) _loadProfile();
  }

  Future<void> _saveProfile() async {
    final success = await ApiService.updateClientProfile({
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Profile updated successfully' : 'Profile update failed')),
    );
    if (success) _loadProfile();
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.selectLoginMethod, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      NetworkProfileAvatar(
                        imagePath: _profile?['profile_picture'],
                        fallbackAsset: 'assets/images/user_profile.png',
                        fallbackIcon: Icons.person_rounded,
                        radius: 58,
                      ),
                      FloatingActionButton.small(
                        heroTag: 'clientImagePick',
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        child: _isUploading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.camera_alt_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _field('Username', _usernameController, Icons.person_rounded),
                _field('Email', _emailController, Icons.email_rounded),
                _field('Phone', _phoneController, Icons.phone_rounded),
                _field('Address', _addressController, Icons.location_on_rounded, maxLines: 2),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save Profile'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Open Settings'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ],
            ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
