import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.black),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
