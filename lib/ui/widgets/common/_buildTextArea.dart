import 'package:flutter/material.dart';

class TextAreaWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final String? errorText;

  const TextAreaWidget({
    Key? key,
    this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
    this.maxLines = 4,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  State<TextAreaWidget> createState() => _TextAreaWidgetState();
}

class _TextAreaWidgetState extends State<TextAreaWidget> {
  late TextEditingController _internalController;
  static const primaryBlue = Color(0xff3B82F6);

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _internalController,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey[200],
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}