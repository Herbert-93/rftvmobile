import 'package:flutter/material.dart';
import '../models/donation_config.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_title.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _api = ApiService();
  late Future<DonationConfig> _configFuture;
  int? _selectedAmount;
  String? _selectedMethod;
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _configFuture = _api.getDonationConfig().then((config) {
      _selectedAmount = config.presetAmounts.isNotEmpty ? config.presetAmounts[1.clamp(0, config.presetAmounts.length - 1)] : null;
      _selectedMethod = config.paymentMethods.isNotEmpty ? config.paymentMethods.first.id : null;
      return config;
    });
  }

  Future<void> _submit(DonationConfig config) async {
    if (_selectedAmount == null || _selectedMethod == null || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose an amount, payment method and phone number.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await _api.submitDonation(
        amount: _selectedAmount!,
        currency: config.currency,
        paymentMethod: _selectedMethod!,
        phoneNumber: _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Your donation was recorded.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<DonationConfig>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final config = snapshot.data;
          if (config == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text('Support RF', style: AppText.sora(size: 15.5)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: AppColors.brandGradient),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.card_giftcard_rounded, color: AppColors.cyan),
                      const SizedBox(height: 10),
                      Text('Keep family TV on air', style: AppText.sora(size: 16, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(
                        'Your gift helps us bring trusted news, faith and family programming to homes across Uganda.',
                        style: AppText.inter(size: 11.5, color: Colors.white.withOpacity(0.78)),
                      ),
                    ],
                  ),
                ),
              ),
              const SectionTitle(title: 'Choose an amount'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 2.1,
                  children: config.presetAmounts.map((amount) {
                    final active = amount == _selectedAmount;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAmount = amount),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? AppColors.navy : Colors.white,
                          border: Border.all(color: active ? AppColors.navy : AppColors.line, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          amount.toString(),
                          style: AppText.sora(size: 13, color: active ? Colors.white : AppColors.navy),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SectionTitle(title: 'Payment method'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: config.paymentMethods.where((m) => m.enabled).map((m) {
                    final active = m.id == _selectedMethod;
                    final color = Color(int.parse(m.color.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = m.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: active ? color.withOpacity(0.07) : Colors.white,
                          border: Border.all(color: active ? color : AppColors.line, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name, style: AppText.sora(size: 13)),
                                  Text(m.sub, style: AppText.inter(size: 11, color: AppColors.slate)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Mobile money number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: PrimaryButton(
                  label: 'Donate ${config.currency} ${_selectedAmount ?? ''}',
                  gradient: AppColors.flameGradient,
                  loading: _submitting,
                  onPressed: () => _submit(config),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
