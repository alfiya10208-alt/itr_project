import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  final List<Map<String, dynamic>> messages = [];

  // QUICK SUGGESTIONS
  final List<String> suggestions = [
    "Best places in Maharashtra",
    "Places to visit in Pune",
    "Best beaches",
    "Best historical places",
    "Best mountains",
    "Places to visit in Solapur",
    "Best food places",
    "Hotels near me",
  ];

  // SEND MESSAGE
  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({
        "message": message,
        "isUser": true,
      });
    });

    messageController.clear();

    // Simple chatbot response
    Future.delayed(const Duration(milliseconds: 500), () {
      String reply = getBotReply(message);

      if (!mounted) return;

      setState(() {
        messages.add({
          "message": reply,
          "isUser": false,
        });
      });

      scrollToBottom();
    });

    scrollToBottom();
  }

  // BOT RESPONSES
  String getBotReply(String message) {
    final text = message.toLowerCase();

    if (text.contains("pune")) {
      return "📍 Pune is a great place to explore!\n\n"
          "🏛️ Aga Khan Palace\n"
          "🏰 Shaniwar Wada\n"
          "⛰️ Sinhagad Fort\n"
          "🌳 Osho Garden\n\n"
          "You can also use the Map, Lodge and Food buttons "
          "on the place cards.";
    }

    if (text.contains("beach")) {
      return "🏖️ Some beautiful beaches in Maharashtra are:\n\n"
          "• Alibaug Beach\n"
          "• Tarkarli Beach\n"
          "• Ganpatipule Beach\n"
          "• Kashid Beach\n"
          "• Murud Beach\n\n"
          "Perfect for a relaxing trip! 🌊";
    }

    if (text.contains("historical")) {
      return "🏰 Maharashtra has many amazing historical places:\n\n"
          "• Shaniwar Wada\n"
          "• Aga Khan Palace\n"
          "• Raigad Fort\n"
          "• Pratapgad Fort\n"
          "• Sinhagad Fort\n\n"
          "History and architecture lovers will definitely enjoy these places!";
    }

    if (text.contains("food")) {
      return "🍽️ You should definitely try these Maharashtra dishes:\n\n"
          "🥪 Vada Pav\n"
          "🍛 Misal Pav\n"
          "🥘 Pav Bhaji\n"
          "🍚 Puran Poli\n"
          "🌶️ Bhakri with Bharit\n\n"
          "Use the Food button on a place card to find food near your destination.";
    }

    if (text.contains("mountain") ||
        text.contains("mountains")) {
      return "⛰️ Maharashtra has many beautiful mountain destinations!\n\n"
          "• Lonavala\n"
          "• Khandala\n"
          "• Mahabaleshwar\n"
          "• Matheran\n"
          "• Igatpuri\n"
          "• Sinhagad\n\n"
          "Perfect destinations for nature, trekking and amazing views! 🌄";
    }

    if (text.contains("solapur")) {
      return "📍 Solapur is a wonderful destination to explore!\n\n"
          "You can discover places such as:\n"
          "🏛️ Siddheshwar Temple\n"
          "🌊 Hipparga Lake\n"
          "🛕 Akkalkot\n"
          "🛕 Tulja Bhavani Temple\n\n"
          "Solapur is also famous for its traditional food and textiles. 😊";
    }

    if (text.contains("hotel") ||
        text.contains("hotels") ||
        text.contains("lodge")) {
      return "🏨 Looking for a place to stay?\n\n"
          "Select any destination from the home page and "
          "use the Lodge button on the place card. "
          "It will help you find hotels near that location.";
    }

    if (text.contains("maharashtra") ||
        text.contains("places")) {
      return "🌄 Maharashtra has something for every traveler!\n\n"
          "🏰 Historical forts\n"
          "🏖️ Beautiful beaches\n"
          "⛰️ Mountains and hill stations\n"
          "🛕 Temples and spiritual places\n"
          "🍽️ Delicious local food\n\n"
          "Which type of place would you like to explore?";
    }

    if (text.contains("hello") ||
        text.contains("hi") ||
        text.contains("hey")) {
      return "Hello! 👋\n\n"
          "I'm your Maharashtra travel assistant. "
          "I can help you find places, beaches, historical sites, "
          "food and hotels. 😊";
    }

    return "I'm here to help you explore Maharashtra! 😊\n\n"
        "You can ask me about:\n"
        "🏰 Historical places\n"
        "🏖️ Beaches\n"
        "⛰️ Mountains\n"
        "🍽️ Food\n"
        "🏨 Hotels\n"
        "📍 Places in Pune\n\n"
        "Try one of the quick suggestions below!";
  }

  // SCROLL TO BOTTOM
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      // APP BAR
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy,
                color: Colors.black,
              ),
            ),

            SizedBox(width: 10),

            Text(
              "Explore Assistant",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [

          // CHAT AREA
          Expanded(
            child: messages.isEmpty
                ? _welcomeScreen()
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return _messageBubble(
                  message["message"],
                  message["isUser"],
                );
              },
            ),
          ),

          // QUICK SUGGESTIONS
          _suggestions(),

          // MESSAGE INPUT
          _messageInput(),
        ],
      ),
    );
  }

  // WELCOME SCREEN
  Widget _welcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(22),

              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.travel_explore,
                size: 55,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Explore Maharashtra",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Hi! 👋 I'm your travel assistant.\n"
                  "Ask me anything about Maharashtra.",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Try asking:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,

              children: suggestions
                  .map(
                    (suggestion) => _suggestionButton(
                  suggestion,
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // QUICK SUGGESTIONS
  Widget _suggestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        15,
        10,
        15,
        5,
      ),

      color: Colors.white,

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: Row(
          children: suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),

              child: _suggestionButton(
                suggestion,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // SUGGESTION BUTTON
  Widget _suggestionButton(String text) {
    return OutlinedButton(
      onPressed: () {
        sendMessage(text);
      },

      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,

        side: BorderSide(
          color: Colors.grey.shade300,
        ),

        backgroundColor: Colors.grey.shade50,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }

  // MESSAGE BUBBLE
  Widget _messageBubble(
      String message,
      bool isUser,
      ) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.of(context).size.width * .75,
        ),

        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: isUser
              ? Colors.black
              : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),

            bottomLeft:
            Radius.circular(isUser ? 18 : 4),

            bottomRight:
            Radius.circular(isUser ? 4 : 18),
          ),

          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
              ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            if (!isUser) ...[
              const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.black,
              ),

              const SizedBox(width: 8),
            ],

            Flexible(
              child: Text(
                message,

                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Colors.black87,

                  fontSize: 15,

                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MESSAGE INPUT
  Widget _messageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        10,
        15,
        15,
      ),

      color: Colors.white,

      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: messageController,

              textInputAction:
              TextInputAction.send,

              onSubmitted: (value) {
                sendMessage(value);
              },

              decoration: InputDecoration(
                hintText:
                "Ask about Maharashtra...",

                filled: true,

                fillColor:
                Colors.grey.shade100,

                prefixIcon: const Icon(
                  Icons.chat_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(30),

                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),

            child: IconButton(
              onPressed: () {
                sendMessage(
                  messageController.text,
                );
              },

              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}