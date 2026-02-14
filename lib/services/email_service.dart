import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // ✅ EmailJS CONFIG (FINAL)
  static const String _serviceId = 'service_ksuh0mn';
  static const String _templateId = 'template_vxcjguo';
  static const String _publicKey = '0ehcOi2aYJH5WSuNo';

  static Future<void> sendOtpEmail(String email, String otp) async {
    final url =
    Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          // ⚠️ MUST MATCH TEMPLATE VARIABLES
          'to_email': email,
          'otp': otp,
        },
      }),
    );

    // 🧪 Debug (agar koi issue ho)
    if (response.statusCode != 200) {
      print('EmailJS Error: ${response.statusCode}');
      print(response.body);
      throw Exception('OTP email send failed');
    }
  }
}
