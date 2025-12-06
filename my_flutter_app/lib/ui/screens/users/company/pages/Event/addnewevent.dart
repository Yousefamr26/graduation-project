import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/event-model.dart';
import '../../../../../widgets/CustomDropdown.dart';
import '../../../../../widgets/_buildDateField.dart';
import '../../../../../widgets/_buildSection.dart';
import '../../../../../widgets/_buildTextArea.dart';
import '../../../../../widgets/_buildTextField.dart';
import '../../../../../widgets/_buildUploadContainer.dart';

class CreateEditEventScreen extends StatefulWidget {
  final EventModel? event;

  const CreateEditEventScreen({this.event, super.key});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _capacityController;
  late TextEditingController _pointsAttendanceController;
  late TextEditingController _pointsParticipationController;

  // Dropdown values
  String? _eventType;
  String? _eventMode;

  final List<String> _eventTypes = [
    "Company Tour",
    "Hiring Event",
    "Workshop",
    "Networking Event",
    "Tech Talk",
    "Bootcamp Preview"
  ];

  final List<String> _eventModes = ["Online", "Onsite", "Hybrid"];

  // Image
  String? _coverImagePath;

  // Eligibility
  double _minPoints = 0;
  List<String> _eligibilityFilters = [];
  bool _inviteOnly = false;
  int _eligibleStudents = 245;

  // Registration
  bool _allowWaitingList = false;
  bool _sendAutoEmail = false;

  // Validation
  Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  bool get isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (isEditMode) {
      final event = widget.event!;
      _titleController = TextEditingController(text: event.title);
      _descController = TextEditingController(text: event.description);
      _locationController = TextEditingController(text: event.location);
      _startDateController = TextEditingController(text: event.startDate);
      _endDateController = TextEditingController(text: event.endDate);
      _startTimeController = TextEditingController(text: event.startTime);
      _endTimeController = TextEditingController(text: event.endTime);
      _capacityController = TextEditingController(text: event.capacity.toString());
      _pointsAttendanceController = TextEditingController(text: event.pointsAttendance.toString());
      _pointsParticipationController = TextEditingController(text: event.pointsParticipation.toString());

      _eventType = event.type;
      _eventMode = event.mode;
      _coverImagePath = event.coverImagePath;
      _minPoints = event.minPoints;
      _eligibilityFilters = List<String>.from(event.eligibilityFilters);
      _inviteOnly = event.inviteOnly;
      _eligibleStudents = event.eligibleStudents;
      _allowWaitingList = event.allowWaitingList;
      _sendAutoEmail = event.sendAutoEmail;
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _locationController = TextEditingController();
      _startDateController = TextEditingController();
      _endDateController = TextEditingController();
      _startTimeController = TextEditingController();
      _endTimeController = TextEditingController();
      _capacityController = TextEditingController();
      _pointsAttendanceController = TextEditingController();
      _pointsParticipationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _pointsAttendanceController.dispose();
    _pointsParticipationController.dispose();
    super.dispose();
  }

  bool _validateForm({required bool isDraft}) {
    setState(() => _errors = {});
    bool isValid = true;

    if (isDraft) return true;

    if (_titleController.text.trim().isEmpty) {
      _errors['title'] = 'Event title is required';
      isValid = false;
    }

    if (_descController.text.trim().isEmpty) {
      _errors['description'] = 'Description is required';
      isValid = false;
    }

    if (_eventType == null) {
      _errors['eventType'] = 'Event type is required';
      isValid = false;
    }

    if (_eventMode == null) {
      _errors['eventMode'] = 'Event mode is required';
      isValid = false;
    }

    if ((_eventMode == "Onsite" || _eventMode == "Hybrid") && _locationController.text.trim().isEmpty) {
      _errors['location'] = 'Location is required for onsite/hybrid events';
      isValid = false;
    }

    if (_startDateController.text.trim().isEmpty) {
      _errors['startDate'] = 'Start date is required';
      isValid = false;
    }

    if (_endDateController.text.trim().isEmpty) {
      _errors['endDate'] = 'End date is required';
      isValid = false;
    }

    if (_startTimeController.text.trim().isEmpty) {
      _errors['startTime'] = 'Start time is required';
      isValid = false;
    }

    if (_endTimeController.text.trim().isEmpty) {
      _errors['endTime'] = 'End time is required';
      isValid = false;
    }

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      _errors['capacity'] = 'Valid capacity is required';
      isValid = false;
    }

    // Validate date range
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      try {
        final startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
        final endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
        if (endDate.isBefore(startDate)) {
          _errors['endDate'] = 'End date must be after start date';
          isValid = false;
        }
      } catch (e) {
        _errors['startDate'] = 'Invalid date format';
        isValid = false;
      }
    }

    if (!isValid) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return isValid;
  }

  Future<void> _handleSubmit({required bool isDraft, bool isEdit = false}) async {
    if (_isSubmitting) return;

    if (!_validateForm(isDraft: isDraft)) return;

    setState(() => _isSubmitting = true);

    try {
      final eventModel = _createEventModel(
        status: isEdit ? widget.event!.status : (isDraft ? "Draft" : "Published"),
        id: isEdit ? widget.event!.id : null,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        String message = isEdit
            ? 'Changes saved successfully!'
            : isDraft
            ? 'Draft saved successfully!'
            : 'Event published successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, eventModel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  EventModel _createEventModel({required String status, String? id}) {
    return EventModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      coverImagePath: _coverImagePath,
      type: _eventType,
      mode: _eventMode,
      location: _locationController.text.trim(),
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      minPoints: _minPoints,
      eligibilityFilters: _eligibilityFilters,
      inviteOnly: _inviteOnly,
      eligibleStudents: _eligibleStudents,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      allowWaitingList: _allowWaitingList,
      sendAutoEmail: _sendAutoEmail,
      pointsAttendance: int.tryParse(_pointsAttendanceController.text) ?? 0,
      pointsParticipation: int.tryParse(_pointsParticipationController.text) ?? 0,
      status: status,
      date: isEditMode
          ? widget.event!.date
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  Future<void> _pickDate(TextEditingController controller, String field) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff3B82F6),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff3B82F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _errors[field] = null;
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller, String field) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff3B82F6),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff3B82F6),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: const Color(0xff3B82F6),
              dayPeriodTextColor: const Color(0xff3B82F6),
              dialHandColor: const Color(0xff3B82F6),
              dialBackgroundColor: const Color(0xff3B82F6).withOpacity(0.1),
              entryModeIconColor: const Color(0xff3B82F6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
        _errors[field] = null;
      });
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _eligibilityFilters.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          if (val) {
            _eligibilityFilters.add(label);
          } else {
            _eligibilityFilters.remove(label);
          }
        });
      },
      selectedColor: const Color(0xff1893ff).withOpacity(0.2),
      checkmarkColor: const Color(0xff1893ff),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Event" : "Create New Event",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff1893ff),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Event Information
              SectionWidget(
                title: "Event Information",
                children: [
                  TextFieldWidget(
                    controller: _titleController,
                    label: "Event Title",
                    hint: "e.g., Vodafone Tech Tour",
                  ),
                  if (_errors['title'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['title']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextAreaWidget(
                    controller: _descController,
                    label: "Description",
                    hint: "Write a clear description of the event...",
                  ),
                  if (_errors['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['description']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  UploadContainerWidget(
                    title: "Upload Event Image",
                    selectedImagePath: _coverImagePath,
                    onImageChanged: (path) {
                      setState(() {
                        _coverImagePath = path;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Event Type & Mode
              SectionWidget(
                title: "Event Type & Mode",
                children: [
                  CustomDropdown(
                    label: "Event Type",
                    items: _eventTypes,
                    value: _eventType,
                    onChanged: (v) {
                      setState(() {
                        _eventType = v;
                        _errors['eventType'] = null;
                      });
                    },
                    hint: "Select Event Type",
                  ),
                  if (_errors['eventType'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['eventType']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: "Mode",
                    items: _eventModes,
                    value: _eventMode,
                    onChanged: (v) {
                      setState(() {
                        _eventMode = v;
                        _errors['eventMode'] = null;
                      });
                    },
                    hint: "Select Mode",
                  ),
                  if (_errors['eventMode'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['eventMode']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_eventMode == "Onsite" || _eventMode == "Hybrid") ...[
                    TextFieldWidget(
                      controller: _locationController,
                      label: "Location",
                      hint: "Campus Hall / Building…",
                    ),
                    if (_errors['location'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _errors['location']!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Date & Time
              SectionWidget(
                title: "Date & Time",
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DateFieldWidget(
                          controller: _startDateController,
                          label: "Start Date",
                          hint: "Select date",
                          errorText: _errors['startDate'],
                          onTap: () => _pickDate(_startDateController, 'startDate'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DateFieldWidget(
                          controller: _endDateController,
                          label: "End Date",
                          hint: "Select date",
                          errorText: _errors['endDate'],
                          onTap: () => _pickDate(_endDateController, 'endDate'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          controller: _startTimeController,
                          label: "Start Time",
                          hint: "Select time",
                          suffixIcon: const Icon(Icons.access_time, color: Color(0xff1893ff)),
                          onTap: () => _pickTime(_startTimeController, 'startTime'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFieldWidget(
                          controller: _endTimeController,
                          label: "End Time",
                          hint: "Select time",
                          suffixIcon: const Icon(Icons.access_time, color: Color(0xff1893ff)),
                          onTap: () => _pickTime(_endTimeController, 'endTime'),
                        ),
                      ),
                    ],
                  ),
                  if (_errors['startTime'] != null || _errors['endTime'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['startTime'] ?? _errors['endTime'] ?? '',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Eligibility Settings
              SectionWidget(
                title: "Eligibility Settings",
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Minimum Required Points:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff1893ff),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${_minPoints.round()} pts",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        value: _minPoints,
                        label: "${_minPoints.round()} pts",
                        activeColor: const Color(0xff1893ff),
                        inactiveColor: Colors.grey.shade300,
                        onChanged: (v) => setState(() => _minPoints = v),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Additional Filters:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildFilterChip("Completed Roadmap"),
                          _buildFilterChip("≥50% Courses"),
                          _buildFilterChip("High Communication Skills"),
                          _buildFilterChip("High Technical Skills"),
                          _buildFilterChip("Top 20% Progress"),
                        ],
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        title: const Text("Invite Only Students Above Criteria"),
                        value: _inviteOnly,
                        onChanged: (v) => setState(() => _inviteOnly = v),
                        activeColor: const Color(0xff1893ff),
                        activeTrackColor: const Color(0xffa3c9ff),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Capacity & Registration
              SectionWidget(
                title: "Capacity & Registration",
                children: [
                  TextFieldWidget(
                    controller: _capacityController,
                    label: "Max Attendees",
                    hint: "e.g., 100",
                    keyboardType: TextInputType.number,
                  ),
                  if (_errors['capacity'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errors['capacity']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text("Allow Waiting List"),
                    value: _allowWaitingList,
                    onChanged: (v) => setState(() => _allowWaitingList = v),
                    activeColor: const Color(0xff1893ff),
                    activeTrackColor: const Color(0xffa3c9ff),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text("Send Auto Email to Eligible Students"),
                    value: _sendAutoEmail,
                    onChanged: (v) => setState(() => _sendAutoEmail = v),
                    activeColor: const Color(0xff1893ff),
                    activeTrackColor: const Color(0xffa3c9ff),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Event Rewards
              SectionWidget(
                title: "Event Rewards",
                children: [
                  TextFieldWidget(
                    controller: _pointsAttendanceController,
                    label: "Points for Attendance",
                    hint: "e.g., 50 pts",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    controller: _pointsParticipationController,
                    label: "Points for Full Participation",
                    hint: "e.g., 100 pts",
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (isEditMode)
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: false, isEdit: true),
                  icon: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1893ff),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: true),
                        icon: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1893ff)),
                          ),
                        )
                            : const Icon(Icons.save_outlined),
                        label: const Text("Save Draft"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff1893ff),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xff1893ff), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: false),
                        icon: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.publish),
                        label: const Text("Publish"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1893ff),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}