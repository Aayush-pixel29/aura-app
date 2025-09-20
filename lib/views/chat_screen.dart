import 'package:aura_app/providers/aura_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// The ChatMessage class can stay here for now
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    // UPDATED: Call the provider's method instead of using a local list
    Provider.of<AuraChatProvider>(context, listen: false).sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Talk it Out")),
      body: Column(
        children: [
          Expanded(
            // UPDATED: Wrap the list in a Consumer to listen for changes
            child: Consumer<AuraChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages.reversed.toList()[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  // The helper widgets below do not need any changes
  Widget _buildMessageBubble(ChatMessage message) {
    // ... same code as before
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.deepPurple[400] : Colors.grey[800],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    // ... same code as before
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(hintText: "Send a message..."),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}