import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Shown after LoginScreen sends an SMS code. Confirming here signs the user
/// in — AuthGate then takes over navigation automatically.
class OtpScreen extends StatefulWidget {
  const OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.confirmPhoneCode(
        verificationId: widget.verificationId,
        smsCode: code,
        phoneNumber: widget.phoneNumber,
      );
      // AuthGate's authStateChanges stream picks this up and swaps to HomeShell.
    } catch (e) {
      setState(() => _error = 'Incorrect code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the code', style: AppText.sora(size: 24)),
              const SizedBox(height: 6),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}',
                style: AppText.inter(size: 13, color: AppColors.slate),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: AppText.sora(size: 24, letterSpacing: 10),
                decoration:
                    const InputDecoration(counterText: '', hintText: '••••••'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!,
                    style: AppText.inter(size: 12.5, color: AppColors.ember)),
              ],
              const SizedBox(height: 14),
              PrimaryButton(
                  label: 'Verify',
                  icon: Icons.check_rounded,
                  onPressed: _verify,
                  loading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
