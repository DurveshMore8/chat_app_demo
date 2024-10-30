import 'dart:convert';

import 'package:chat_app_demo/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatListScreen extends StatefulWidget {
  final String name;
  final String email;
  const ChatListScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List users = [];

  @override
  void initState() {
    super.initState();
    getChats();
  }

  void getChats() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.45.79:3000/users',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    users = jsonDecode(response.body)['users'];

    users.removeWhere(
      (element) => element['email'] == widget.email,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat List',
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          final user = users[index];

          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  name: widget.name,
                  email: widget.email,
                  recipientName: user['name'],
                  recipientEmail: user['email'],
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              child: Text(
                user['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
