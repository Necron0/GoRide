import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// SignUpScreen - dengan validasi per-field
// ══════════════════════════════════════════════════════

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  final Map<String, bool> _touched = {
    'name': false,
    'phone': false,
    'email': false,
  };
  final Map<String, String?> _errors = {
    'name': null,
    'phone': null,
    'email': null,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (v.trim().length < 2) return 'Nama minimal 2 karakter';
    if (!RegExp(r"^[a-zA-Z\s'.-]+$").hasMatch(v.trim())) {
      return 'Nama hanya boleh huruf dan spasi';
    }
    return null;
  }

  String? _validatePhone(String v) {
    final c = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (c.isEmpty) return 'Nomor HP tidak boleh kosong';
    if (!RegExp(r'^\d+$').hasMatch(c)) return 'Hanya boleh berisi angka';
    if (c.length < 8) return 'Minimal 8 digit';
    if (c.length > 13) return 'Maksimal 13 digit';
    return null;
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  void _touch(String field, String value) {
    setState(() {
      _touched[field] = true;
      if (field == 'name') _errors['name'] = _validateName(value);
      if (field == 'phone') _errors['phone'] = _validatePhone(value);
      if (field == 'email') _errors['email'] = _validateEmail(value);
    });
  }

  bool get _allValid =>
      _touched.values.every((t) => t) &&
      _errors.values.every((e) => e == null);

  Future<void> _handleSubmit() async {
    // Touch semua field
    setState(() {
      _touched.updateAll((_, __) => true);
      _errors['name'] = _validateName(_nameController.text);
      _errors['phone'] = _validatePhone(_phoneController.text);
      _errors['email'] = _validateEmail(_emailController.text);
    });

    if (!_allValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFF0077FF), shape: BoxShape.circle),
                    child: const Icon(Icons.directions_bike_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('goride',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0A0A),
                          letterSpacing: -0.5)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Create Account',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A))),
              const SizedBox(height: 6),
              const Text('Join GoRide and ride anywhere!',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 28),

              _buildValidatedField(
                label: 'Full Name',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                type: TextInputType.name,
                fieldKey: 'name',
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              _buildValidatedField(
                label: 'Phone Number',
                hint: '812-3456-7890',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                type: TextInputType.phone,
                fieldKey: 'phone',
                validator: _validatePhone,
                prefix: '+62',
              ),
              const SizedBox(height: 14),
              _buildValidatedField(
                label: 'Email',
                hint: 'contoh@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                type: TextInputType.emailAddress,
                fieldKey: 'email',
                validator: _validateEmail,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF0077FF).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Create Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                              color: Color(0xFF0077FF),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required TextInputType type,
    required String fieldKey,
    required String? Function(String) validator,
    String? prefix,
  }) {
    final bool isTouched = _touched[fieldKey] ?? false;
    final String? error = _errors[fieldKey];
    final bool isValid = isTouched && error == null && controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444))),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: error != null
                  ? const Color(0xFFFF3B30)
                  : isValid
                      ? const Color(0xFF34C759)
                      : const Color(0xFFDDEEFF),
              width: (error != null || isValid) ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            color: error != null
                ? const Color(0xFFFFF5F5)
                : isValid
                    ? const Color(0xFFF0FFF5)
                    : const Color(0xFFF5F9FF),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color(0xFFDDEEFF), width: 1.5)),
                  ),
                  child: Text(prefix,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0077FF))),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(icon,
                      color: error != null
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF0077FF),
                      size: 20),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: type,
                  onChanged: (v) => _touch(fieldKey, v),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFFBBCCDD)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),
              ),
              if (isTouched)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: error != null
                        ? const Icon(Icons.error_rounded,
                            color: Color(0xFFFF3B30),
                            size: 18,
                            key: ValueKey('err'))
                        : const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF34C759),
                            size: 18,
                            key: ValueKey('ok')),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 13, color: Color(0xFFFF3B30)),
                      const SizedBox(width: 4),
                      Text(error,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF3B30),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}