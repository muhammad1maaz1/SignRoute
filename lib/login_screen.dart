import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_screen_1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color brandYellow = Color(0xFFFFD400);

  // 🔹 USERNAME instead of email
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  OverlayEntry? _currentOverlay;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _removeCurrentOverlay();
    super.dispose();
  }

  void _removeCurrentOverlay() {
    try {
      _currentOverlay?.remove();
    } catch (_) {}
    _currentOverlay = null;
  }

  void _showTopMessage(String message,
      {bool isError = true, Duration duration = const Duration(seconds: 2)}) {
    _removeCurrentOverlay();

    final overlay = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _TopToastWidget(message: message, isError: isError),
        ),
      ),
    );

    _currentOverlay = overlay;
    Overlay.of(context)?.insert(overlay);

    Future.delayed(duration, _removeCurrentOverlay);
  }

  // 🔍 USERNAME → EMAIL (Firestore)
  Future<String?> _getEmailFromUsername(String username) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      return snap.docs.first['email'];
    }
    return null;
  }

  /// 🔥 LOGIN USING USERNAME + PASSWORD
  Future<void> _onLogin() async {
    final username = _username.text.trim();
    final password = _password.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showTopMessage('Please enter username & password');
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔹 Find email from username
      final email = await _getEmailFromUsername(username);

      if (email == null) {
        setState(() => _loading = false);
        _showTopMessage('Username not found');
        return;
      }

      // 🔹 Firebase login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() => _loading = false);
      _showTopMessage('Login successful', isError: false);

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/user');
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      if (e.code == 'wrong-password') {
        _showTopMessage('Wrong password');
      } else {
        _showTopMessage('Login failed');
      }
    } catch (_) {
      setState(() => _loading = false);
      _showTopMessage('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.23,
                  child: Image.asset('assets/images/bee_login.png'),
                ),
                const SizedBox(height: 20),

                // 🔹 USERNAME FIELD
                _inputBox(
                  controller: _username,
                  hint: 'Username',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                // 🔹 PASSWORD FIELD
                _inputBox(
                  controller: _password,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotScreen1(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

class _TopToastWidget extends StatelessWidget {
  final String message;
  final bool isError;

  const _TopToastWidget({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.yellow.shade300 : Colors.green.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
