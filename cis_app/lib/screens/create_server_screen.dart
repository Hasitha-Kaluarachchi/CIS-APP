import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({super.key});

  @override
  State<CreateServerScreen> createState() => _CreateServerScreenState();
}

class _CreateServerScreenState extends State<CreateServerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _registrationController = TextEditingController();
  final _evidenceController = TextEditingController();

  final List<String> _categories = const [
    'Health Services',
    'Education Services',
    'Business Services',
    'Administrative Services',
  ];

  final List<String> _sectors = const ['Government', 'Private Sector'];

  String _selectedCategory = 'Health Services';
  String _selectedSector = 'Government';
  bool _isLoading = false;
  bool _initialized = false;
  Map<String, dynamic>? _editingServer;

  bool get _isEditMode => _editingServer != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _editingServer = Map<String, dynamic>.from(args);
      _nameController.text = (_editingServer?['server_name'] ?? '').toString();
      _descriptionController.text = (_editingServer?['description'] ?? '').toString();
      _locationController.text = (_editingServer?['location'] ?? '').toString();
      _contactController.text = (_editingServer?['contact_number'] ?? '').toString();
      _emailController.text = (_editingServer?['email'] ?? '').toString();
      _websiteController.text = (_editingServer?['website'] ?? '').toString();
      _registrationController.text = (_editingServer?['registration_number'] ?? '').toString();
      _evidenceController.text = (_editingServer?['verification_evidence'] ?? '').toString();

      final category = (_editingServer?['category'] ?? '').toString();
      final sector = (_editingServer?['sector'] ?? '').toString();
      if (_categories.contains(category)) _selectedCategory = category;
      if (_sectors.contains(sector)) _selectedSector = sector;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _registrationController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = _isEditMode
        ? await ApiService.updateServer(
            serverId: (_editingServer?['_id'] ?? '').toString(),
            serverName: _nameController.text.trim(),
            category: _selectedCategory,
            sector: _selectedSector,
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
            contactNumber: _contactController.text.trim(),
            email: _emailController.text.trim(),
            website: _websiteController.text.trim(),
            registrationNumber: _registrationController.text.trim(),
            verificationEvidence: _evidenceController.text.trim(),
          )
        : await ApiService.createServer(
            serverName: _nameController.text.trim(),
            category: _selectedCategory,
            sector: _selectedSector,
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
            contactNumber: _contactController.text.trim(),
            email: _emailController.text.trim(),
            website: _websiteController.text.trim(),
            registrationNumber: _registrationController.text.trim(),
            verificationEvidence: _evidenceController.text.trim(),
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? (_isEditMode ? 'Updated' : 'Created'))),
    );

    if (response['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Business Server' : 'Create Business Server')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF004D48).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Business server is the large public business profile clients can search and open. Verification evidence will be reviewed by app developers/admins.',
                style: TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 18),
            _textField('Business / Server Name', _nameController, Icons.business_rounded),
            _dropdown(
              label: 'Category',
              icon: Icons.category_rounded,
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            _dropdown(
              label: 'Sector',
              icon: Icons.apartment_rounded,
              value: _selectedSector,
              items: _sectors,
              onChanged: (value) => setState(() => _selectedSector = value!),
            ),
            _textField('Description / About', _descriptionController, Icons.description_rounded, maxLines: 4),
            _textField('Location', _locationController, Icons.location_on_rounded),
            _textField('Contact Number', _contactController, Icons.phone_rounded),
            _textField('Email', _emailController, Icons.email_rounded, keyboardType: TextInputType.emailAddress),
            _textField('Website', _websiteController, Icons.language_rounded, requiredField: false),
            const SizedBox(height: 12),
            const Text('Organization Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _textField(
              'Registration Number',
              _registrationController,
              Icons.badge_rounded,
              requiredField: false,
            ),
            _textField(
              'Evidence / Note / Document Link',
              _evidenceController,
              Icons.verified_user_rounded,
              maxLines: 3,
              requiredField: false,
            ),
            const SizedBox(height: 8),
            Text(
              _isEditMode
                  ? 'If you change evidence, verification status becomes pending again until developer approval.'
                  : 'After creation, this server will be visible to clients but the verified badge appears only after developer approval.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_isEditMode ? Icons.save_rounded : Icons.add_business_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Create Server'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
