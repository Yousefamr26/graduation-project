import 'package:flutter/material.dart';
import '../../../../data/models/CompanyMember.dart';

class TeamTab extends StatefulWidget {
  final List<CompanyMember> teamMembers;
  const TeamTab({super.key, required this.teamMembers});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xff3B82F6)),
            SizedBox(width: 8),
            Text('Add New Member', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person, color: Color(0xff3B82F6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff3B82F6), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Field
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.work, color: Color(0xff3B82F6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff3B82F6), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xff3B82F6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff3B82F6), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _roleController.clear();
              _emailController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // إضافة العضو الجديد
                final newMember = CompanyMember(
                  name: _nameController.text,
                  role: _roleController.text,
                  email: _emailController.text,
                );

                setState(() {
                  widget.teamMembers.add(newMember);
                });

                // مسح الحقول
                _nameController.clear();
                _roleController.clear();
                _emailController.clear();

                // إغلاق الـ Dialog
                Navigator.pop(context);

                // رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member added successfully!'),
                    backgroundColor: Color(0xff3B82F6),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Member',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.business, color: Color(0xff3B82F6)),
                      SizedBox(width: 8),
                      Text('Recruitment Team', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(Icons.add, size: 20, color: Color(0xff3B82F6)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.teamMembers.map((member) => _buildTeamMember(member)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(CompanyMember member) {
    final initials = member.name.split(' ').map((n) => n[0]).join();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xff3B82F6).withOpacity(0.1), const Color(0xff06B6D4).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xff3B82F6), Color(0xff06B6D4)]),
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(member.role, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(member.email, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}