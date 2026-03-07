import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFF385798).withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Color(0xFF385798),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
