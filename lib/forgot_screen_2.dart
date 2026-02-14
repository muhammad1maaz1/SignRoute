import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/otp_service.dart';
import 'services/email_service.dart';

class ForgotScreen2 extends StatefulWidget {
  final String email;

  const ForgotScreen2({
    super.key,
    required this.email,
  });

  @override
  State<ForgotScreen2> createState() => _ForgotScreen2State();
}

class _ForgotScreen2State extends State<ForgotScreen2>
    with TickerProviderStateMixin {
  static const Color screenBg = Colors.white;
  static const Color brandYellow = Color(0xFFFFD400);

  final _d1 = TextEditingController();
  final _d2 = TextEditingController();
  final _d3 = TextEditingController();
  final _d4 = TextEditingController();

  final _f1 = FocusNode();
  final _f2 = FocusNode();
  final _f3 = FocusNode();
  final _f4 = FocusNode();

  bool _isVerifying = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).requestFocus(_f1));

    _sendOtpFirstTime();
  }

  @override
  void dispose() {
    _d1.dispose();
    _d2.dispose();
    _d3.dispose();
    _d4.dispose();
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _f4.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // 🔔 Toast
  void _showToast(String msg, Color bg) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  // 📩 Send OTP first time
  Future<void> _sendOtpFirstTime() async {
    final otp = OtpService.generateOtp();
    await OtpService.saveOtp(widget.email, otp);
    await EmailService.sendOtpEmail(widget.email, otp);

    setState(() => _resendSeconds = 30);
    _resendTimer?.cancel();
    _resendTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _resendSeconds--;
            if (_resendSeconds <= 0) {
              timer.cancel();
              _resendSeconds = 0;
            }
          });
        });
  }

  // 🔁 Resend OTP
  void _onResend() async {
    if (_resendSeconds > 0) return;

    final otp = OtpService.generateOtp();
    await OtpService.saveOtp(widget.email, otp);
    await EmailService.sendOtpEmail(widget.email, otp);

    _showToast('OTP resent', Colors.black87);

    setState(() => _resendSeconds = 30);
    _resendTimer?.cancel();
    _resendTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _resendSeconds--;
            if (_resendSeconds <= 0) {
              timer.cancel();
              _resendSeconds = 0;
            }
          });
        });
  }

  // ✅ Verify OTP & send Firebase reset email
  void _verifyCode() async {
    if (_d1.text.isEmpty ||
        _d2.text.isEmpty ||
        _d3.text.isEmpty ||
        _d4.text.isEmpty) {
      _showToast('Enter complete OTP', Colors.redAccent);
      return;
    }

    final otp = '${_d1.text}${_d2.text}${_d3.text}${_d4.text}';

    setState(() => _isVerifying = true);

    final isValid = await OtpService.verifyOtp(widget.email, otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (!isValid) {
      _showToast('Invalid or expired OTP', Colors.redAccent);
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: widget.email);

      _showToast('Password reset email sent', Colors.green);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      _showToast('Failed to send reset email', Colors.redAccent);
    }
  }

  Widget _box(TextEditingController c, FocusNode f, FocusNode? next) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: c,
        focusNode: f,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(counterText: ''),
        onChanged: (v) {
          if (v.isNotEmpty && next != null) {
            FocusScope.of(context).requestFocus(next);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check your Email',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'OTP sent to ${widget.email}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(_d1, _f1, _f2),
                  _box(_d2, _f2, _f3),
                  _box(_d3, _f3, _f4),
                  _box(_d4, _f4, null),
                ],
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: _resendSeconds == 0 ? _onResend : null,
                child: Text(
                  _resendSeconds == 0
                      ? 'Resend OTP'
                      : 'Resend in $_resendSeconds s',
                  style: TextStyle(
                    color:
                    _resendSeconds == 0 ? brandYellow : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandYellow,
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Verify Code',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
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
