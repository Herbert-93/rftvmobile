import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _agreed = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      setState(() =>
          _error = 'Please agree to the Terms of Service and Privacy Policy.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      // AuthGate will pick up the new session and route to HomeShell.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Could not create account');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/icon/icon.png',
                      width: 44, height: 44, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Text('Join the family', style: AppText.sora(size: 25)),
                const SizedBox(height: 5),
                Text('Create an account to stream RF anywhere.',
                    style: AppText.inter(size: 13.5, color: AppColors.slate)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: Validators.name,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: 'name@email.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: '+256 700 000 000',
                      prefixIcon: Icon(Icons.phone_outlined)),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Create password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 6),
                Text(
                  'Use 7+ characters with upper & lower case letters, a number, and a symbol.',
                  style: AppText.inter(size: 11, color: AppColors.slateLight),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                            'I agree to the Terms of Service and Privacy Policy.',
                            style: AppText.inter(
                                size: 11.5, color: AppColors.slate)),
                      ),
                    ),
                  ],
                ),
                if (_error != null)
                  Text(_error!,
                      style: AppText.inter(size: 12.5, color: AppColors.ember)),
                const SizedBox(height: 8),
                PrimaryButton(
                    label: 'Create account',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _submit,
                    loading: _loading),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        style:
                            AppText.inter(size: 12.5, color: AppColors.slate),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                              text: 'Log in',
                              style: AppText.inter(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                  color: AppColors.ember)),
                        ],
                      ),
                    ),
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
