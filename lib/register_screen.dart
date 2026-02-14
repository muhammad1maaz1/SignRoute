import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const Color brandYellow = Color(0xFFFFD400);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  OverlayEntry? _currentOverlay;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
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
      {bool isError = true, Duration duration = const Duration(seconds: 3)}) {
    _removeCurrentOverlay();
    final topPadding = MediaQuery.of(context).padding.top;

    final overlay = OverlayEntry(
      builder: (_) => Positioned(
        top: topPadding + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _TopToastWidget(
            message: message,
            isError: isError,
          ),
        ),
      ),
    );

    _currentOverlay = overlay;
    Overlay.of(context)?.insert(overlay);

    Future.delayed(duration, () {
      if (_currentOverlay == overlay) _removeCurrentOverlay();
    });
  }

  /// 🔥 FIREBASE REGISTER + FIRESTORE SAVE
  Future<void> _onRegister() async {
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();

    final RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showTopMessage('Please fill all fields');
      return;
    }

    if (!nameRegex.hasMatch(username)) {
      _showTopMessage('Username must contain only letters');
      return;
    }

    if (username.length < 3) {
      _showTopMessage('Username must be at least 3 characters');
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      _showTopMessage('Use a valid Gmail address');
      return;
    }

    if (password.length < 8) {
      _showTopMessage('Password must be at least 8 characters');
      return;
    }

    setState(() => _loading = true);

    try {
      /// 🔹 Firebase Auth
      UserCredential userCred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// 🔹 Firestore (username save)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'username': username,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _loading = false);

      _showTopMessage('Registered successfully!', isError: false);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String msg = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        msg = 'Email already registered';
      } else if (e.code == 'weak-password') {
        msg = 'Weak password';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email';
      }

      _showTopMessage(msg);
    } catch (_) {
      setState(() => _loading = false);
      _showTopMessage('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.23,
                    child: Image.asset('assets/images/bee_login.png'),
                  ),
                  const SizedBox(height: 18),

                  _inputField(_username, 'Username', Icons.person_outline),
                  const SizedBox(height: 14),

                  _inputField(
                    _email,
                    'Email',
                    Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: _inputBoxDecoration(),
                    child: TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        contentPadding: const EdgeInsets.all(14),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                          : const Text(
                        'REGISTER',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType? inputType,
      }) {
    return Container(
      decoration: _inputBoxDecoration(),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _TopToastWidget extends StatelessWidget {
  final String message;
  final bool isError;

  const _TopToastWidget({required this.message, required this.isError});

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
  