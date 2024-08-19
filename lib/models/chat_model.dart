import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Message {
  final String content;
  final bool isUser;

  Message({required this.content, required this.isUser});

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        isUser: json['isUser'],
      );
}

class ChatSession {
  String id;
  String title;
  List<Message> messages;

  ChatSession({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'],
        title: json['title'],
        messages:
            (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
      );
}

class ChatModel extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => _sessions;

  ChatSession? _currentSession;
  ChatSession? get currentSession => _currentSession;

  final TextEditingController messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  ChatModel() {
    _loadSessions();
  }

  void createNewSession() {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      messages: [],
    );
    _sessions.add(newSession);
    _currentSession = newSession;
    _saveSessions();
    notifyListeners();
  }

  void selectSession(ChatSession session) {
    _currentSession = session;
    notifyListeners();
  }

  void sendMessage(String content) async {
    if (content.isEmpty) return;
    if (_currentSession == null) createNewSession();

    // Add user message
    _currentSession!.messages.add(Message(content: content, isUser: true));
    notifyListeners();

    messageController.clear();

    // Update session title if it's the first message
    if (_currentSession!.messages.length == 1) {
      _currentSession!.title =
          content.length > 30 ? content.substring(0, 30) + '...' : content;
    }

    // Get AI response
    try {
      final response = await _chatService.getResponse(content);
      _currentSession!.messages.add(Message(content: response, isUser: false));
    } catch (e) {
      _currentSession!.messages
          .add(Message(content: 'Error: ${e.toString()}', isUser: false));
    }

    _saveSessions();
    notifyListeners();
  }

  void _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');
    if (sessionsJson != null) {
      final List<dynamic> decodedSessions = jsonDecode(sessionsJson);
      _sessions = decodedSessions.map((s) => ChatSession.fromJson(s)).toList();
      if (_sessions.isNotEmpty) {
        _currentSession = _sessions.last;
      }
      notifyListeners();
    }
  }

  void _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString('chat_sessions', sessionsJson);
  }
}
