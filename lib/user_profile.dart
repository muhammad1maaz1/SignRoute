// lib/user_profile.dart
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color brandYellow = Color(0xFFFFD400);

  bool accessibilityMode = true;
  bool notificationsOn = false;

  // ---------------- TOP BAR ----------------
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'User Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ---------------- STRAIGHT YELLOW HEADER ----------------
  Widget _headerBox() {
    return Container(
      height: 90,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      color: brandYellow,
      child: SafeArea(child: _topBar()),
    );
  }

  // ---------------- BEAUTIFUL PROFILE PICTURE SECTION ----------------
  Widget _avatarSection() {
    return Transform.translate(
      offset: const Offset(0, -1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            // Profile Picture + Edit Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // ---- PROFILE PHOTO CIRCLE ----
                Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: brandYellow, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/profile_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // ---- CAMERA BUTTON ----
                Material(
                  color: brandYellow,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      // TODO: open image picker
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.camera_alt_rounded,
                          size: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // USER NAME
            const Text(
              'Muhammad Maaz',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            // SUBTEXT + IMPROVED HAND ICON
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Connecting through signs',
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(width: 6),
                Icon(Icons.front_hand_rounded,
                    size: 20, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INFO ROW ----------------
  Widget _infoRow(IconData icon, String label, String value,
      {VoidCallback? onTap, Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),

            trailing ??
                const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // ---------------- PERSONAL DETAILS CARD ----------------
  Widget _personalDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              'Personal Details',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(),

          _infoRow(Icons.email_outlined, 'Email', 'mahazmahazali70@gmail.com'),
          _infoRow(Icons.language, 'Language', 'English'),
          _infoRow(Icons.calendar_today_outlined, 'Member since', 'June 2025'),

          // Accessibility toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.accessibility_new, color: Colors.black54),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Accessibility Mode',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),

                Switch(
                  value: accessibilityMode,
                  activeColor: brandYellow,
                  onChanged: (v) => setState(() => accessibilityMode = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PREFERENCES CARD ----------------
  Widget _preferencesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Preferences',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const Divider(),

          // Notification Toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Row(
              children: [
                const Icon(Icons.notifications_none, color: Colors.black54),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text('Notification',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Switch(
                  value: notificationsOn,
                  activeColor: brandYellow,
                  onChanged: (v) => setState(() => notificationsOn = v),
                ),
              ],
            ),
          ),

          // Voice
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.volume_up_outlined, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text('Voice Type',
                          style: TextStyle(fontWeight: FontWeight.w700))),
                  Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),

          // Theme
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Theme',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('Light', style: TextStyle(color: Colors.black54)),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),

          // Language
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.language, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text('Language',
                          style: TextStyle(fontWeight: FontWeight.w700))),
                  Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          _headerBox(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _avatarSection(),
                  _personalDetailsCard(),
                  _preferencesCard(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
