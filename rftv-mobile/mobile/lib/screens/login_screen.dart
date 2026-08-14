import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _authService = AuthService();

  String _mode = 'email'; // 'email' or 'phone'
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signIn(
          email: _email.text.trim(), password: _password.text);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Could not sign in');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendPhoneCode() async {
    final digits = _phone.text.trim();
    if (digits.length < 9) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    // Default to Uganda's country code if the user didn't type a leading "+".
    final fullPhone = digits.startsWith('+')
        ? digits
        : '+256${digits.replaceFirst(RegExp(r'^0'), '')}';
    setState(() {
      _loading = true;
      _error = null;
    });
    await _authService.startPhoneVerification(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(
                verificationId: verificationId, phoneNumber: fullPhone),
          ),
        );
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = message;
        });
      },
      onAutoVerified: () {
        if (mounted) setState(() => _loading = false);
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null && mounted) {
        setState(() => _googleLoading = false); // user cancelled the picker
      }
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/icon/icon.png',
                      width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(height: 18),
                Text('Welcome back', style: AppText.sora(size: 25)),
                const SizedBox(height: 5),
                Text("Log in to keep watching your family's channel.",
                    style: AppText.inter(size: 13.5, color: AppColors.slate)),
                const SizedBox(height: 22),

                // Email / Phone mode switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: AppColors.cream2,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeTab(
                          label: 'Email',
                          active: _mode == 'email',
                          onTap: () => setState(() {
                            _mode = 'email';
                            _error = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _ModeTab(
                          label: 'Phone',
                          active: _mode == 'phone',
                          onTap: () => setState(() {
                            _mode = 'phone';
                            _error = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (_mode == 'email') ...[
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'name@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded)),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimum 6 characters'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        if (_email.text.trim().isEmpty) {
                          setState(() => _error =
                              'Enter your email above first, then tap "Forgot password?"');
                          return;
                        }
                        try {
                          await _authService
                              .sendPasswordReset(_email.text.trim());
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Password reset email sent — check your inbox.')),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() => _error =
                              e.message ?? 'Could not send reset email');
                        }
                      },
                      child: Text('Forgot password?',
                          style: AppText.inter(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.sky)),
                    ),
                  ),
                  if (_error != null)
                    Text(_error!,
                        style:
                            AppText.inter(size: 12.5, color: AppColors.ember)),
                  const SizedBox(height: 8),
                  PrimaryButton(
                      label: 'Log in',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _submitEmail,
                      loading: _loading),
                ] else ...[
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        hintText: '0700 000 000',
                        prefixIcon: Icon(Icons.phone_outlined)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                      "We'll text you a 6-digit code. Standard rates may apply.",
                      style: AppText.inter(size: 11, color: AppColors.slate)),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style:
                            AppText.inter(size: 12.5, color: AppColors.ember)),
                  ],
                  const SizedBox(height: 14),
                  PrimaryButton(
                      label: 'Send code',
                      icon: Icons.sms_outlined,
                      onPressed: _sendPhoneCode,
                      loading: _loading),
                ],

                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.line)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or continue with',
                          style: AppText.inter(
                              size: 11.5, color: AppColors.slateLight)),
                    ),
                    const Expanded(child: Divider(color: AppColors.line)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _googleLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.line, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _googleLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.g_mobiledata_rounded,
                            size: 24, color: AppColors.navy),
                    label: Text('Continue with Google',
                        style: AppText.sora(size: 13.5, color: AppColors.navy)),
                  ),
                ),

                const SizedBox(height: 26),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SignupScreen())),
                    child: RichText(
                      text: TextSpan(
                        style:
                            AppText.inter(size: 12.5, color: AppColors.slate),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                              text: 'Sign up',
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

class _ModeTab extends StatelessWidget {
  const _ModeTab(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 6)
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppText.sora(
                size: 12.5, color: active ? AppColors.navy : AppColors.slate)),
      ),
    );
  }
}
