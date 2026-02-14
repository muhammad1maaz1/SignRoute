import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// 🔢 Generate 4-digit OTP
  static String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// 💾 Save OTP with 5 minutes expiry
  static Future<void> saveOtp(String email, String otp) async {
    final expiryTime =
    DateTime.now().add(const Duration(minutes: 5));

    await _firestore
        .collection('password_otps')
        .doc(email)
        .set({
      'otp': otp,
      'expiresAt': Timestamp.fromDate(expiryTime),
    });
  }

  /// ✅ Verify OTP
  static Future<bool> verifyOtp(
      String email, String enteredOtp) async {
    final doc = await _firestore
        .collection('password_otps')
        .doc(email)
        .get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    final savedOtp = data['otp'];
    final expiry =
    (data['expiresAt'] as Timestamp).toDate();

    // ⏰ Expired
    if (DateTime.now().isAfter(expiry)) {
      await doc.reference.delete();
      return false;
    }

    // 🎯 Match
    if (savedOtp == enteredOtp) {
      await doc.reference.delete();
      return true;
    }

    return false;
  }
}
