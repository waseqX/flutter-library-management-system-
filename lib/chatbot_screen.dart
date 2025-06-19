import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class chatbotScreen extends StatefulWidget {
  const chatbotScreen({super.key});

  @override
  State<chatbotScreen> createState() => _chatbotScreenState();
}

class _chatbotScreenState extends State<chatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late GenerativeModel _model;
  late var _chat;

  // دیتابیس ساختگی ما:
  final Map<String, String> fakeDatabase = {
    'flutter': 'Flutter is an open-source UI software development kit created by Google.',
    'dart': 'Dart is the programming language used to develop Flutter apps.',
    'gemini': 'Gemini is Google\'s AI model for generative tasks.',
    'ai': 'Artificial Intelligence is the simulation of human intelligence processes by machines.'
  };

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    const apiKey = 'اینجا کلید API خودت را بگذار';

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 100),
    );
    _chat = _model.startChat();
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "message": message});
    });

    // جستجو در دیتابیس لوکال
    String lowerMessage = message.toLowerCase();
    if (fakeDatabase.containsKey(lowerMessage)) {
      setState(() {
        _messages.add({"sender": "bot", "message": fakeDatabase[lowerMessage]});
      });
      return;
    }

    // اگر در دیتابیس نبود => به Gemini API درخواست بده
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);

      setState(() {
        _messages.add({"sender": "bot", "message": response.text});
      });
    } catch (e) {
      setState(() {
        _messages.add({"sender": "error", "message": e.toString()});
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg['sender'] == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.android,
                color: Colors.white,
              ),
            ),
          if (!isUser) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUser ? Colors.orangeAccent : Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                msg['message'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
