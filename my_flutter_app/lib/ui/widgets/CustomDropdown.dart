import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String? label; // بقى اختياري
  final List<String> items;
  final String? value;
  final Function(String?)? onChanged;
  final String? hint;

  const CustomDropdown({
    super.key,
    this.label, // مش required دلوقتي
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: Colors.blue,
              hint: Text(
                widget.hint ?? "Select",
                style: TextStyle(color: Colors.grey[600]),
              ),
              value: selectedValue,
              items: widget.items
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedValue = val;
                });
                if (widget.onChanged != null) widget.onChanged!(val);
              },
              selectedItemBuilder: (context) {
                return widget.items
                    .map(
                      (item) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: const TextStyle(
                          color: Color(0xff1893ff),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                    .toList();
              },
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }
}
