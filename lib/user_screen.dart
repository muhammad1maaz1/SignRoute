import 'package:flutter/material.dart';
import 'speak_type.dart';
import 'sign_to_text_speech.dart';
import 'chat_history.dart';
import 'download_sign.dart';
import 'user_notification.dart';

// >>> NEW IMPORT FOR PROFILE SCREEN <<<
import 'user_profile.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  static const Color brandYellow = Color(0xFFFFD400);
  static const Color screenBg = Colors.white;

  // ------------------ TOP BAR ------------------
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: brandYellow,
      padding: const EdgeInsets.fromLTRB(14, 30, 14, 14),

      child: Row(
        children: [
          // ------------ PROFILE BUTTON (NOW WORKING) ------------
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),

          const Spacer(),

          // ------------ NOTIFICATION BUTTON ------------
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UserNotificationScreen()),
              );
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ------------------ GREETING ------------------
  Widget _buildGreetingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning 👋',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  "Let's connect through signs today!",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // SAME BEE IMAGE USED IN PROFILE SCREEN
          SizedBox(
            width: 62,
            height: 62,
            child: Image.asset(
              'assets/images/splash_bee.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ USER AVATAR ------------------
  Widget _buildAvatar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarHeight = (size.height * 0.22).clamp(110.0, 260.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Image.asset(
          'assets/images/user_screen_avatar.png',
          height: avatarHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ------------------ SECTION ITEM ------------------
  Widget _sectionItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ MAIN BUILD ------------------
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: screenBg,
      body: Column(
        children: [
          _buildTopBar(context),

          Expanded(
            child: SingleChildScrollView(
              padding:
              EdgeInsets.fromLTRB(0, 6, 0, bottomInset + bottomSafe + 22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(context),
                  _buildAvatar(context),
                  const SizedBox(height: 30),

                  // SPEAK OR TYPE
                  _sectionItem(
                    'Speak or Type Message',
                    Icons.mic_none,
                    brandYellow,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SpeakTypeScreen()),
                      );
                    },
                  ),

                  // SIGN TO TEXT / SPEECH
                  _sectionItem(
                    'Sign to Text / Speech',
                    Icons.pan_tool_alt_outlined,
                    Colors.blueAccent,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignToTextSpeechScreen()),
                      );
                    },
                  ),

                  // CHAT HISTORY
                  _sectionItem(
                    'Chat History',
                    Icons.chat_bubble_outline,
                    Colors.green,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChatHistoryScreen()),
                      );
                    },
                  ),

                  // DOWNLOAD NEW SIGNS
                  _sectionItem(
                    'Download New Signs',
                    Icons.download,
                    Colors.orange,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DownloadSignScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
