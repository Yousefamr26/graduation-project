import 'package:flutter/material.dart';

class ActivityRowWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final String difficulty;
  final int points;
  final Function(String) onDifficultyChanged;
  final Function(int) onPointsChanged;
  final Function() onRemove;

  const ActivityRowWidget({
    super.key,
    required this.titleController,
    required this.descController,
    required this.difficulty,
    required this.points,
    required this.onDifficultyChanged,
    required this.onPointsChanged,
    required this.onRemove,
  });

  @override
  State<ActivityRowWidget> createState() => _ActivityRowWidgetState();
}

class _ActivityRowWidgetState extends State<ActivityRowWidget> {
  late TextEditingController _pointsController;
  late String _selectedDifficulty;

  final List<String> difficulties = ["Easy", "Medium", "Hard"];

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: widget.points.toString());
    _selectedDifficulty = widget.difficulty;
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Activity", style: TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
              )
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              labelText: "Activity Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: "Difficulty",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: difficulties.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedDifficulty = v);
                      widget.onDifficultyChanged(v);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 80,
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Pts",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    int pts = int.tryParse(val) ?? 0;
                    widget.onPointsChanged(pts);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
