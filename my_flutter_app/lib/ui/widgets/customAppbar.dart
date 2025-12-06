import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;
  final List<Widget>? actions;
  final double height;

  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.height = 120,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3B82F6), Color(0xff06B6D4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: height -1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// LEADING (optional)
                leading ?? const SizedBox(width: 40),

                /// TITLE (optional)
                Expanded(
                  child: Text(
                    title ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// ACTIONS (optional)
                Row(children: actions ?? const []),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
