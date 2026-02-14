import 'package:flutter/material.dart';

class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFFFFD400),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          _notificationItem(
            "New sign pack available!",
            "Download the latest signs from the Download section.",
            Icons.download_for_offline,
          ),

          _notificationItem(
            "Chat history updated",
            "Your recent chats are now synced.",
            Icons.chat_bubble_outline,
          ),

          _notificationItem(
            "App update available",
            "A new update is ready to install.",
            Icons.system_update,
          ),

        ],
      ),
    );
  }

  Widget _notificationItem(
      String title, String message, IconData icon) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.amber.shade700),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(message,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
