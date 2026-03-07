// QuizQuestionsWidget.dart - Updated to match _convertQuestions structure
import 'package:flutter/material.dart';

class QuizQuestionsWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? initialQuestions;
  final Function(List<Map<String, dynamic>>) onQuestionsChanged;

  const QuizQuestionsWidget({
    Key? key,
    this.initialQuestions,
    required this.onQuestionsChanged,
  }) : super(key: key);

  @override
  State<QuizQuestionsWidget> createState() => QuizQuestionsWidgetState();
}

class QuizQuestionsWidgetState extends State<QuizQuestionsWidget> {
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null) {
      questions = List.from(widget.initialQuestions!);
    }
  }

  void _addQuestion() {
    setState(() {
      questions.add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "text": "", // ✅ Changed from "text" to match backend
        "type": "MCQ",
        "options": ["", "", "", ""],
        "correctAnswer": "",
        "points": 5,
      });
    });
    widget.onQuestionsChanged(questions);
  }

  void _removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
    widget.onQuestionsChanged(questions);
  }

  void _updateQuestion(int index, Map<String, dynamic> updatedQuestion) {
    setState(() {
      questions[index] = updatedQuestion;
    });
    widget.onQuestionsChanged(questions);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (questions.isEmpty)
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz_outlined, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    "No Questions Yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Click below to add questions manually",
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ...questions.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> question = entry.value;
            return _QuestionCard(
              question: question,
              questionNumber: index + 1,
              onUpdate: (updated) => _updateQuestion(index, updated),
              onRemove: () => _removeQuestion(index),
            );
          }).toList(),

          SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1893ff), Color(0xff0d7de8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1893ff).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: Icon(Icons.add_circle_outline, size: 22),
              label: Text(
                "Add Question",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 54),
              ),
            ),
          ),

          SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onRemove;

  const _QuestionCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.onUpdate,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _textController;
  late TextEditingController _pointsController;
  late List<TextEditingController> _optionControllers;
  late String _selectedType;
  late String _correctAnswer;

  @override
  void initState() {
    super.initState();

    // ✅ Support both "text" and "questionText" for compatibility
    String questionText = widget.question['text']?.toString() ??
        widget.question['questionText']?.toString() ??
        '';
    _textController = TextEditingController(text: questionText);

    _pointsController = TextEditingController(
      text: (widget.question['points'] ?? 5).toString(),
    );

    // ✅ Normalize type: MultipleChoice -> MCQ
    String qType = widget.question['type']?.toString() ?? 'MCQ';
    if (qType == 'MultipleChoice') qType = 'MCQ';
    _selectedType = qType;

    _correctAnswer = widget.question['correctAnswer']?.toString() ?? '';

    // ✅ Handle options from backend
    List options = widget.question['options'] ?? [];
    if (options.isEmpty) {
      options = _selectedType == 'TrueFalse' ? ["True", "False"] : ["", "", "", ""];
    }
    _optionControllers = options
        .map((opt) => TextEditingController(text: opt.toString()))
        .toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyUpdate() {
    // ✅ Use "text" as the main field (matches _convertQuestions output)
    Map<String, dynamic> updated = {
      "id": widget.question['id'],
      "text": _textController.text, // ✅ Main field
      "type": _selectedType, // ✅ Already normalized (MCQ/TrueFalse)
      "points": int.tryParse(_pointsController.text) ?? 5,
      "correctAnswer": _correctAnswer,
    };

    if (_selectedType == 'MCQ') {
      updated['options'] = _optionControllers.map((c) => c.text).toList();
    } else if (_selectedType == 'TrueFalse') {
      updated['options'] = ["True", "False"];
    }

    widget.onUpdate(updated);
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
    _notifyUpdate();
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
      _notifyUpdate();
    }
  }

  Color _getTypeColor() {
    switch (_selectedType) {
      case 'MCQ':
        return Color(0xff1893ff);
      case 'TrueFalse':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTypeColor().withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor().withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getTypeColor().withOpacity(0.1),
                  _getTypeColor().withOpacity(0.05)
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(),
                        _getTypeColor().withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    "Q${widget.questionNumber}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: widget.onRemove,
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question Type
                Text(
                  "Question Type",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildTypeChip(
                      "Multiple Choice",
                      "MCQ",
                      Icons.checklist,
                    ),
                    SizedBox(width: 12),
                    _buildTypeChip(
                      "True/False",
                      "TrueFalse",
                      Icons.check_circle_outline,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Question Text
                Text(
                  "Question",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Enter your question here...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    maxLines: 3,
                    onChanged: (_) => _notifyUpdate(),
                  ),
                ),
                SizedBox(height: 16),

                // Points
                Row(
                  children: [
                    Text(
                      "Points",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.stars, color: Colors.amber[700], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _pointsController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                              onChanged: (_) => _notifyUpdate(),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Answer Options
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Answer Options",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "(Select the correct one)",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Spacer(),
                        if (_selectedType == 'MCQ')
                          InkWell(
                            onTap: _addOption,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff1893ff).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Color(0xff1893ff),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Add",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xff1893ff),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Options List
                    ..._optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      bool isCorrect = controller.text == _correctAnswer;

                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green[50] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.grey[300]!,
                            width: isCorrect ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: controller.text,
                              groupValue: _correctAnswer,
                              onChanged: (value) {
                                setState(() {
                                  _correctAnswer = value ?? '';
                                });
                                _notifyUpdate();
                              },
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText:
                                  "Option ${String.fromCharCode(65 + index)}",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                enabled: _selectedType != 'TrueFalse',
                                style: TextStyle(
                                  color: isCorrect
                                      ? Colors.green[900]
                                      : Colors.grey[800],
                                  fontWeight: isCorrect
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                onChanged: (value) {
                                  if (isCorrect) {
                                    setState(() {
                                      _correctAnswer = value;
                                    });
                                  }
                                  _notifyUpdate();
                                },
                              ),
                            ),
                            if (isCorrect)
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      "Correct",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_selectedType == 'MCQ' &&
                                _optionControllers.length > 2)
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red[300],
                                  size: 18,
                                ),
                                onPressed: () => _removeOption(index),
                                constraints: BoxConstraints(),
                                padding: EdgeInsets.all(8),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Warning if no correct answer
                    if (_correctAnswer.isEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Please select the correct answer",
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
            _correctAnswer = '';
            if (_selectedType == 'TrueFalse') {
              // Clear existing controllers
              for (var controller in _optionControllers) {
                controller.dispose();
              }
              _optionControllers = [
                TextEditingController(text: "True"),
                TextEditingController(text: "False"),
              ];
            } else if (_selectedType == 'MCQ' && _optionControllers.length < 4) {
              // Ensure at least 4 options for MCQ
              for (var controller in _optionControllers) {
                controller.dispose();
              }
              _optionControllers = List.generate(
                4,
                    (index) => TextEditingController(),
              );
            }
          });
          _notifyUpdate();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [
                _getTypeColor(),
                _getTypeColor().withOpacity(0.8)
              ],
            )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _getTypeColor() : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}