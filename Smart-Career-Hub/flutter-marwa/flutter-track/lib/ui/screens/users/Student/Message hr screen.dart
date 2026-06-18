import 'package:flutter/material.dart';

class MessageHRScreen extends StatefulWidget {
  const MessageHRScreen({super.key});

  @override
  State<MessageHRScreen> createState() => _MessageHRScreenState();
}

class _MessageHRScreenState extends State<MessageHRScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isHR': true,
      'sender': 'Sarah - HR Manager',
      'text':
          'Hello! Welcome to the Smart Career Hub HR support. How can I assist you today?',
      'time': '10:00 AM',
      'avatar': 'S',
    },
    {
      'isHR': false,
      'sender': 'You',
      'text': 'Hi! I have a question about the upcoming internship program.',
      'time': '10:02 AM',
      'avatar': 'J',
    },
    {
      'isHR': true,
      'sender': 'Sarah - HR Manager',
      'text':
          'Of course! The internship program applications are now open. Deadline is June 30th. Make sure your profile is complete before applying. Would you like more details?',
      'time': '10:03 AM',
      'avatar': 'S',
    },
  ];

  final List<Map<String, String>> _hrContacts = [
    {'name': 'Sarah Ahmed', 'role': 'HR Manager', 'status': 'Online', 'avatar': 'S'},
    {'name': 'Mohamed Ali', 'role': 'Recruitment Specialist', 'status': 'Away', 'avatar': 'M'},
    {'name': 'Nour Hassan', 'role': 'Career Advisor', 'status': 'Online', 'avatar': 'N'},
  ];

  String _selectedHR = 'Sarah Ahmed';
  bool _showContacts = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'isHR': false,
        'sender': 'You',
        'text': text,
        'time': _currentTime(),
        'avatar': 'J',
      });
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _messages.add({
            'isHR': true,
            'sender': 'Sarah - HR Manager',
            'text':
                'Thank you for your message! I\'ll get back to you shortly. Feel free to check our FAQ section for quick answers.',
            'time': _currentTime(),
            'avatar': 'S',
          });
        });
        _scrollToBottom();
      });
    });
    _scrollToBottom();
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => setState(() => _showContacts = !_showContacts),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  _hrContacts
                      .firstWhere((c) => c['name'] == _selectedHR)['avatar']!,
                  style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedHR,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const Text('Online',
                      style:
                          TextStyle(color: Colors.greenAccent, fontSize: 11)),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // HR contacts dropdown
          if (_showContacts)
            Container(
              color: Colors.white,
              child: Column(
                children: _hrContacts
                    .map((hr) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1565C0),
                            child: Text(hr['avatar']!,
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(hr['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(hr['role']!),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: hr['status'] == 'Online'
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hr['status']!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: hr['status'] == 'Online'
                                      ? Colors.green
                                      : Colors.orange),
                            ),
                          ),
                          onTap: () => setState(() {
                            _selectedHR = hr['name']!;
                            _showContacts = false;
                          }),
                        ))
                    .toList(),
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessage(msg);
              },
            ),
          ),

          // Quick reply chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                'Internship info',
                'Application status',
                'Interview schedule',
                'Documents needed',
              ]
                  .map((q) => GestureDetector(
                        onTap: () {
                          _messageController.text = q;
                          _sendMessage();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blue.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(q,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Input field
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.attach_file,
                        color: Colors.grey.shade600),
                    onPressed: () {}),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 20),
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
    final isHR = msg['isHR'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isHR ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isHR)
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1565C0),
              child: Text(msg['avatar'],
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12)),
            ),
          if (isHR) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHR ? Colors.grey.shade100 : const Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isHR ? 4 : 16),
                  bottomRight: Radius.circular(isHR ? 16 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isHR)
                    Text(
                      msg['sender'],
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0)),
                    ),
                  if (isHR) const SizedBox(height: 2),
                  Text(
                    msg['text'],
                    style: TextStyle(
                      color: isHR ? Colors.black87 : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isHR ? Colors.grey : Colors.white70,
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