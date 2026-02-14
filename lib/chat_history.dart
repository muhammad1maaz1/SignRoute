import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'speak_type.dart'; // SpeakTypeScreen ko import karein

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  static const Color brandYellow = Color(0xFFFFD400);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandYellow,
        elevation: 0,
        title: const Text(
          "Chat History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // Sirf wohi chats dikhao jo Current User ki hain
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('personal_chats')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No History Found.\nGo to Speak & Type to start a chat.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final chatName = data['chatName'] ?? 'Unknown';
              final messages = data['messages'] as List<dynamic>? ?? [];

              // Last message dikhane ke liye
              String lastMessage = "No messages";
              if (messages.isNotEmpty) {
                lastMessage = messages.last['text'] ?? "Image/Audio";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: brandYellow,
                    child: Text(
                      chatName.isNotEmpty ? chatName[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    chatName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Jab click karein, wapas SpeakTypeScreen par jayein purani chat ke sath
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpeakTypeScreen(
                          loadedChatName: chatName,
                          loadedMessages: messages,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}