import 'package:flutter/material.dart';

class CareerAdvisorScreen extends StatefulWidget {
  const CareerAdvisorScreen({super.key});

  @override
  State<CareerAdvisorScreen> createState() => _CareerAdvisorScreenState();
}

class _CareerAdvisorScreenState extends State<CareerAdvisorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text':
          "Good day! I'm your Professional Career Development Assistant. I'm here to guide you through your career advancement journey.",
      'time': 'Just now',
    },
    {
      'isBot': true,
      'text':
          "I specialize in:\n\n• Strategic career path planning\n• Advanced skill development recommendations\n• Industry-specific course guidance\n• Professional roadmap curation\n\nPlease share your current skill set, and I'll provide tailored recommendations for your professional growth.",
      'time': 'Just now',
    },
  ];

  final List<String> _quickActions = [
    'How can I improve my CV?',
    'What skills are in demand?',
    'Career transition advice',
    'Interview preparation tips',
    'Personal branding strategies',
  ];

  final List<String> _skills = [
    'HTML & CSS',
    'JavaScript',
    'React.js',
    'Python',
    'Java',
    'Node.js',
    'SQL',
    'Machine Learning',
    'AWS',
    'Docker',
    'TypeScript',
    'Data Science',
    'Angular',
    'Vue.js',
    'MongoDB',
    'Kubernetes',
    'Flutter',
    'Cybersecurity',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isBot': false,
        'text': text,
        'time': 'Just now',
      });

      _messageController.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _messages.add({
          'isBot': true,
          'text':
              'Great question! Based on your query about "$text", I recommend exploring the latest industry trends and aligning your skills accordingly. Would you like a personalized roadmap?',
          'time': 'Just now',
        });
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1565C0),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Professional Career Assistant",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF1565C0),
                size: 26,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Skills Section
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Color(0xFF1565C0),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Professional Skills & Technologies",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    return GestureDetector(
                      onTap: () => _sendMessage(skill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.cyan.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Quick Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickActions.map((action) {
                return GestureDetector(
                  onTap: () => _sendMessage(action),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Input
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Write your message",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                GestureDetector(
                  onTap: () => _sendMessage(_messageController.text),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1565C0),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final bool isBot = msg['isBot'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade700,
                    Colors.cyan.shade400,
                  ],
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : const Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft:
                      Radius.circular(isBot ? 6 : 22),
                  bottomRight:
                      Radius.circular(isBot ? 22 : 6),
                ),
                border: isBot
                    ? Border.all(color: Colors.blue.shade100)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['text'],
                    style: TextStyle(
                      color: isBot ? Colors.black87 : Colors.white,
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg['time'],
                    style: TextStyle(
                      color: isBot
                          ? Colors.grey.shade500
                          : Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}