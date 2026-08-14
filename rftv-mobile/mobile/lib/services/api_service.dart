import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/program.dart';
import '../models/radio_status.dart';
import '../models/donation_config.dart';
import 'auth_service.dart';

/// Talks to the RF TV backend (Node.js + TypeScript + Firebase Admin).
///
/// IMPORTANT: set [baseUrl] to your deployed backend URL. Update the
/// default below if your Render backend's URL is different from this one.
class ApiService {
  ApiService({this.baseUrl = 'https://rftvmobile.onrender.com'});

  final String baseUrl;
  final AuthService _authService = AuthService();

  /// Strips any trailing slash off [baseUrl] so a value like
  /// "https://host.com/" doesn't turn "/channels" into "//channels" (which
  /// the server treats as a different, unmatched route → 404).
  String get _base => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await _authService.idToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _get(String path) async {
    final res =
        await http.get(Uri.parse('$_base$path'), headers: await _headers());
    return _handle(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$_base$path'),
        headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    throw Exception('API error ${res.statusCode}: ${res.body}');
  }

  Future<List<Channel>> getChannels() async {
    final data = await _get('/channels') as List;
    return data
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Program>> getPrograms({String? channelId}) async {
    final query = channelId != null ? '?channelId=$channelId' : '';
    final data = await _get('/programs$query') as List;
    return data
        .map((e) => Program.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RadioStatus> getRadioStatus() async {
    final data = await _get('/radio') as Map<String, dynamic>;
    return RadioStatus.fromJson(data);
  }

  Future<DonationConfig> getDonationConfig() async {
    final data = await _get('/donations/config') as Map<String, dynamic>;
    return DonationConfig.fromJson(data);
  }

  Future<void> submitDonation({
    required int amount,
    required String currency,
    required String paymentMethod,
    required String phoneNumber,
  }) {
    return _post('/donations', {
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'phoneNumber': phoneNumber,
    });
  }

  Future<void> registerSession({required String name, required String phone}) {
    return _post('/auth/session', {'name': name, 'phone': phone});
  }
}
