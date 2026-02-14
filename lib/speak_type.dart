import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Time format ke liye (Add intl to pubspec.yaml if not exists)

class SpeakTypeScreen extends StatefulWidget {
  // Agar history se aa rahe hain to ye data pass hoga
  final String? loadedChatName;
  final List<dynamic>? loadedMessages;

  const SpeakTypeScreen({
    super.key,
    this.loadedChatName,
    this.loadedMessages,
  });

  @override
  State<SpeakTypeScreen> createState() => _SpeakTypeScreenState();
}

class _SpeakTypeScreenState extends State<SpeakTypeScreen> {
  static const Color brandYellow = Color(0xFFFFD400);

  // MethodChannel to Android (Vosk)
  static const MethodChannel _channel = MethodChannel('vosk_channel');

  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat Data
  List<Map<String, dynamic>> chatMessages = [];
  String? currentChatPersonName; // Jiske sath baat ho rahi hai
  bool isListening = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // Agar history se data aya hai to load karo
    if (widget.loadedChatName != null) {
      currentChatPersonName = widget.loadedChatName;
      if (widget.loadedMessages != null) {
        chatMessages = List<Map<String, dynamic>>.from(widget.loadedMessages!);
      }
    }

    // Vosk Voice Listener
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onPartialResult") {
        final text = _extractText(call.arguments);
        if (text.isNotEmpty) {
          setState(() {
            messageController.text = text;
            // Cursor end pe rakho
            messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: messageController.text.length),
            );
          });
        }
      }

      if (call.method == "onFinalResult") {
        final text = _extractText(call.arguments);
        if (text.isNotEmpty) {
          setState(() {
            messageController.text = text;
            messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: messageController.text.length),
            );
          });
        }
      }
    });
  }

  // JSON string se text nikalna (Vosk ke liye)
  String _extractText(dynamic args) {
    if (args is String) {
      // Basic cleaning, adjust regex based on Vosk output
      return args.replaceAll(RegExp(r'[{}":]'), '').replaceAll('text', '').trim();
    }
    return "";
  }

  // --- FIREBASE LOGIC ---

  // Message Save karna
  Future<void> _saveMessageToFirebase(String text, bool isMe) async {
    if (currentUser == null || currentChatPersonName == null) return;

    final newMessage = {
      'text': text,
      'isMe': isMe,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      chatMessages.add(newMessage);
    });
    _scrollToBottom();

    // Firestore mein update karo
    try {
      final docRef = FirebaseFirestore.instance
          .collection('personal_chats')
          .doc('${currentUser!.uid}_$currentChatPersonName');

      await docRef.set({
        'userId': currentUser!.uid,
        'chatName': currentChatPersonName,
        'lastUpdated': FieldValue.serverTimestamp(),
        'messages': FieldValue.arrayUnion([newMessage]),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving chat: $e");
    }
  }

  // Chat Load karna (jab user list se select kare)
  Future<void> _loadChatFromFirebase(String chatName) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('personal_chats')
          .doc('${currentUser!.uid}_$chatName')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        List<dynamic> msgs = data?['messages'] ?? [];
        setState(() {
          currentChatPersonName = chatName;
          chatMessages = List<Map<String, dynamic>>.from(msgs);
        });
        _scrollToBottom();
      } else {
        // New chat with this name
        setState(() {
          currentChatPersonName = chatName;
          chatMessages = [];
        });
      }
    } catch (e) {
      print("Error loading chat: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    // Agar koi chat selected nahi hai to pehle poocho
    if (currentChatPersonName == null) {
      _showNamePopup(context);
      return;
    }

    _saveMessageToFirebase(messageController.text.trim(), true);
    messageController.clear();
  }

  // Voice Listening Start/Stop
  void _startListening() async {
    try {
      await _channel.invokeMethod('startListening');
    } catch (e) {
      print("Error starting vosk: $e");
    }
  }

  void _stopListening() async {
    try {
      await _channel.invokeMethod('stopListening');
    } catch (e) {
      print("Error stopping vosk: $e");
    }
  }

  // --- POPUP WINDOW ---
  void _showNamePopup(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Start Chat With?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the person's name to save chat history:"),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "e.g. Ali, Shopkeeper",
                  filled: true,
                  fillColor: brandYellow.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brandYellow),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _loadChatFromFirebase(nameController.text.trim());
                }
              },
              child: const Text("Start Chat", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // --- EXISTING CHATS BOTTOM SHEET ---
  void _showExistingChats() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Resume Conversation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('personal_chats')
                      .where('userId', isEqualTo: currentUser?.uid)
                      .orderBy('lastUpdated', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) return const Text("No recent chats found.");

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: brandYellow,
                            child: Text(data['chatName'][0].toString().toUpperCase(),
                                style: const TextStyle(color: Colors.black)),
                          ),
                          title: Text(data['chatName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Tap to resume chat"),
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            _loadChatFromFirebase(data['chatName']);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandYellow,
        elevation: 0,
        title: Text(
          currentChatPersonName == null
              ? "Speak or Type"
              : "Chat: $currentChatPersonName",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Plus Icon for NEW Person
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Chat",
            onPressed: () => _showNamePopup(context),
          ),
          // History List Icon for EXISTING Persons
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Resume Existing",
            onPressed: _showExistingChats,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: chatMessages.isEmpty
                ? Center(
              child: Text(
                currentChatPersonName == null
                    ? "Tap (+) to start a chat with someone\nor just type for temporary chat."
                    : "Start talking with $currentChatPersonName",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final bool isMe = msg['isMe'] ?? true;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? brandYellow : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? "",
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type message...",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: brandYellow,
                    child: const Icon(Icons.send, color: Colors.black, size: 20),
                  ),
                ),
                const SizedBox(width: 8),

                // Mic Button
                GestureDetector(
                  onTap: () {
                    setState(() => isListening = !isListening);
                    if (isListening) {
                      _startListening();
                    } else {
                      _stopListening();
                    }
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isListening ? Colors.redAccent : brandYellow,
                    child: Icon(isListening ? Icons.stop : Icons.mic, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}