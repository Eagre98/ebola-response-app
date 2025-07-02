import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Information Chatbot')),
      body: const Center(
          child: Text('Chat Screen Placeholder',
              style: TextStyle(color: Colors.white))),
    );
  }
}
