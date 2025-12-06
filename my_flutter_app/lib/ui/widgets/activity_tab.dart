import 'package:flutter/material.dart';
import '../../../../data/models/CompanyActivity.dart';

class ActivityTab extends StatelessWidget {
  final List<CompanyActivity> recentActivity;  // ✅ غيرناها من Map لـ CompanyActivity
  const ActivityTab({super.key, required this.recentActivity});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ...recentActivity.asMap().entries.map((entry) {
                final idx = entry.key;
                final activity = entry.value;
                return _buildActivityItem(idx + 1, activity);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(int number, CompanyActivity activity) {  // ✅ غيرناها من Map لـ CompanyActivity
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xff3B82F6), Color(0xff06B6D4)]),
            ),
            child: Center(child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.action, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(activity.detail, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(activity.date, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}