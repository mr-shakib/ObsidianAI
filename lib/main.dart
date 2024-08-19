import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/chat_screen.dart';
import 'models/chat_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatModel(),
      child: MaterialApp(
        title: 'Obsidian AI',
        debugShowCheckedModeBanner: false,  // This line removes the debug banner
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.grey[900],
          scaffoldBackgroundColor: Colors.grey[850],
        ),
        home: ChatScreen(),
      ),
    );
  }
}