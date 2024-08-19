import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';



class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obsidian AI'),
        backgroundColor: Colors.grey[900],
      ),
      drawer: ChatDrawer(),
      body: Column(
        children: [
          Expanded(child: MessageList(scrollController: _scrollController)),
          MessageInput(scrollController: _scrollController),
        ],
      ),
    );
  }
}

class ChatDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[850]),
              child: const Center(
                child: const Text(
                  'Chat Sessions',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                child: const Text('New Chat'),
                onPressed: () {
                  Provider.of<ChatModel>(context, listen: false)
                      .createNewSession();
                  Navigator.pop(context); // Close the drawer
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ChatModel>(
                builder: (context, chatModel, child) {
                  return ListView.builder(
                    itemCount: chatModel.sessions.length,
                    itemBuilder: (context, index) {
                      final session = chatModel.sessions[index];
                      return ListTile(
                        title: Text(session.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        selected: chatModel.currentSession == session,
                        onTap: () {
                          chatModel.selectSession(session);
                          Navigator.pop(context); // Close the drawer
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final ScrollController scrollController;

  const MessageList({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (context, chatModel, child) {
        if (chatModel.currentSession == null) {
          return Center(child: Text('Start a new chat or select an existing one.'));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return ListView.builder(
          controller: scrollController,
          itemCount: chatModel.currentSession!.messages.length,
          itemBuilder: (context, index) {
            final message = chatModel.currentSession!.messages[index];
            return MessageBubble(message: message);
          },
        );
      },
    );
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(isUser: false),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[700],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(
          isUser ? 'lib/assets/user_avatar.jpg' : 'lib/assets/ai_avatar.jpg'),
    );
  }
}

class MessageInput extends StatelessWidget {
  final ScrollController scrollController;

  const MessageInput({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (context, chatModel, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatModel.messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (chatModel.messageController.text.isNotEmpty) {
                    chatModel.sendMessage(chatModel.messageController.text);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

