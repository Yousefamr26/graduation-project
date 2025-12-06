import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime? startDate, DateTime? endDate)? onDatesChanged;

  const DateRangePickerWidget({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.onDatesChanged,
  }) : super(key: key);

  @override
  DateRangePickerWidgetState createState() => DateRangePickerWidgetState(); // ✅ اسم الكلاس بدون underscore
}

// ✅ إزالة الـ underscore عشان يبقى public
class DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? startDate;
  DateTime? endDate;
  final dateFormat = DateFormat('yyyy-MM-dd');
  final Color primaryBlue = const Color(0xff3B82F6);

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  Future<void> pickStartDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => startDate = date);
      widget.onDatesChanged?.call(startDate, endDate);
    }
  }

  Future<void> pickEndDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => endDate = date);
      widget.onDatesChanged?.call(startDate, endDate);
    }
  }

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(Icons.calendar_month, color: primaryBlue),
      hintText: hint,
      hintStyle: TextStyle(color: primaryBlue.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Start Date",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickStartDate,
          child: AbsorbPointer(
            child: TextField(
              decoration: fieldStyle(
                startDate == null
                    ? "Select start date"
                    : dateFormat.format(startDate!),
              ),
              style: TextStyle(color: primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "End Date",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickEndDate,
          child: AbsorbPointer(
            child: TextField(
              decoration: fieldStyle(
                endDate == null
                    ? "Select end date"
                    : dateFormat.format(endDate!),
              ),
              style: TextStyle(color: primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}