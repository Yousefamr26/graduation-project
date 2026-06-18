// ============================================================
// UPDATED DRAWER - student_drawer.dart
// Replace your existing drawer with this file
// ============================================================

import 'package:flutter/material.dart';

// Import your screens here:
// import 'career_advisor_screen.dart';
// import 'settings_screen.dart';
// import 'message_hr_screen.dart';
// import '../calendar/calendar_screen.dart';
// import '../auth/choose_role_screen.dart'; // your choose role screen

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Logo & App Name
            const Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF1565C0),
                  child: Icon(Icons.hub, color: Colors.white, size: 36),
                ),
                SizedBox(height: 8),
                Text(
                  'Smart Career\nHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Calendar',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.event_outlined,
                    label: 'Events',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push to EventsScreen
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.build_outlined,
                    label: 'Workshops',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push to WorkshopsScreen
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    label: 'Internship',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push to InternshipScreen
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Setting',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lightbulb_outline,
                    label: 'Career Tips',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push to CareerTipsScreen
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.chat_outlined,
                    label: 'Message HR',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessageHRScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Close dialog
              Navigator.pop(ctx);
              // Close drawer
              Navigator.pop(context);

              // ✅ LOGOUT: Navigate to ChooseRole screen & clear all history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChooseRoleScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Helper widget for drawer items
// ============================================================
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}


// ============================================================
// PLACEHOLDER - ChooseRoleScreen (reference)
// ============================================================
// This is just a placeholder — replace with your ACTUAL choose_role_screen.dart path
class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose Your Role',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Navigate to student login/home
              },
              child: const Text('Student',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF1565C0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Navigate to HR login/home
              },
              child: const Text('HR / Company',
                  style: TextStyle(
                      color: Color(0xFF1565C0), fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// PLACEHOLDER SCREENS (will be replaced by real screens above)
// ============================================================
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Calendar Screen')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Settings Screen')));
}

class MessageHRScreen extends StatelessWidget {
  const MessageHRScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Message HR Screen')));
}