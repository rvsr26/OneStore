import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../providers/product_provider.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Initial Chat History
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'text': 'Hi! I\'m your AI Personal Stylist & Shopping Expert. 🤖\n\nAsk me to "Find shoes under 100", "Suggest a gift", or "Track my order"!'}
  ];
  
  bool _isTyping = false;

  @override
  void dispose() {
    // 🧹 Cleanup to prevent memory leaks
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    String userMsg = _controller.text.trim();
    
    setState(() {
      _messages.add({'role': 'user', 'text': userMsg});
      _isTyping = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    // 🧠 GET CONTEXT: Pass the actual product catalog to the AI
    // listen: false is correct here (prevents rebuild loop)
    final catalog = Provider.of<ProductProvider>(context, listen: false).products;

    try {
      // 🧠 CALL ADVANCED AI
      String response = await AIService.getAdvancedChatbotResponse(userMsg, catalog);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add({'role': 'bot', 'text': response});
      });
      
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({'role': 'bot', 'text': "Sorry, I'm having trouble connecting right now. Try again later!"});
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({'role': 'bot', 'text': 'History cleared. How can I help you now?'});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final inputFill = isDark ? Colors.grey[800] : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.white : Colors.black, 
              radius: 16,
              child: Icon(Icons.auto_awesome, size: 16, color: isDark ? Colors.black : Colors.white),
            ),
            SizedBox(width: 10),
            Text("AI Shopping Assistant", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: cardColor,
        elevation: 1,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Clear Chat",
            onPressed: _clearChat,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  bool isUser = _messages[i]['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
                      decoration: BoxDecoration(
                        // User: Indigo (Primary), Bot: Card Color
                        color: isUser ? Colors.indigo : cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2)
                          )
                        ],
                      ),
                      child: Text(
                        _messages[i]['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : textColor, 
                          fontSize: 15,
                          height: 1.4
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Typing Indicator
            if (_isTyping) 
              Padding(
                padding: EdgeInsets.only(left: 20, bottom: 15),
                child: Row(
                  children: [
                    SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)),
                    SizedBox(width: 10),
                    Text("AI is analyzing...", style: TextStyle(color: hintColor, fontSize: 12, fontStyle: FontStyle.italic))
                  ],
                ),
              ),
  
            // Input Area
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textColor),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Ask for products, gifts, or help...",
                        hintStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30), 
                          borderSide: BorderSide.none
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: isDark ? Colors.indigoAccent : Colors.black,
                    elevation: 2,
                    onPressed: _sendMessage,
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}