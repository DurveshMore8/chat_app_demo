import 'dart:convert';

import 'package:chat_app_demo/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String name;
  final String email;
  final String recipientName;
  final String recipientEmail;
  const ChatScreen({
    super.key,
    required this.name,
    required this.email,
    required this.recipientName,
    required this.recipientEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  List messages = [];

  @override
  void initState() {
    super.initState();
    getMessages();
    chatService.connect(widget.email);
    chatService.listenForMessages((data) {
      if (mounted) {
        if (data['senderEmail'] == widget.email &&
                data['recipientEmail'] == widget.recipientEmail ||
            data['senderEmail'] == widget.recipientEmail &&
                data['recipientEmail'] == widget.email) {
          setState(() {
            messages.add(data);
            _scrollToEnd();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  Future<void> getMessages() async {
    final response = await http.post(
        Uri.parse(
          'http://192.168.45.79:3000/get-chats',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'senderEmail': widget.email,
          'recipientEmail': widget.recipientEmail,
        }));

    messages = jsonDecode(response.body)['messages'];

    _scrollToEnd();

    setState(() {});
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      chatService.sendMessage({
        'senderName': widget.name,
        'senderEmail': widget.recipientEmail,
        'recipient': widget.recipientName,
        'recipientEmail': widget.email,
        'content': _controller.text.trim(),
      });
      _controller.clear();
    }
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipientName,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Row(
                  mainAxisAlignment: message['senderEmail'] == widget.email
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ).copyWith(
                        bottom: 12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message['content'],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
