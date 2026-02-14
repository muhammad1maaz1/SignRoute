import 'package:flutter/material.dart';
import 'services/otp_service.dart';
import 'forgot_screen_2.dart';

class ForgotScreen1 extends StatefulWidget {
  const ForgotScreen1({super.key});

  @override
  State<ForgotScreen1> createState() => _ForgotScreen1State();
}

class _ForgotScreen1State extends State<ForgotScreen1> {
  static const Color screenBg = Colors.white;
  static const Color brandYellow = Color(0xFFFFD400);

  final TextEditingController _emailCtrl = TextEditingController();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showTopPopup(String message, Color bgColor) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  // ✅ FIXED MAIN LOGIC
  void _onContinue() async {
    final email = _emailCtrl.text.trim().toLowerCase();

    if (email.isEmpty) {
      _showTopPopup('Please enter your email', Colors.redAccent);
      return;
    }

    if (!email.contains('@')) {
      _showTopPopup('Please enter a valid email', Colors.redAccent);
      return;
    }

    try {
      // 🔢 Generate OTP
      final otp = OtpService.generateOtp();

      // 💾 Save OTP (email is key)
      await OtpService.saveOtp(email, otp);

      debugPrint('OTP SENT: $otp');

      _showTopPopup('OTP sent to your email', brandYellow);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotScreen2(email: email),
          ),
        );
      });
    } catch (e) {
      _showTopPopup('Something went wrong', Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: brandYellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: size.width * 0.56,
                        height: size.width * 0.38,
                        margin: const EdgeInsets.only(top: 10),
                        child: Image.asset(
                          'assets/images/forgot_bee.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Forgot Password?',
                        style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter your account email. We will send a code to reset your password.',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email_outlined),
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
