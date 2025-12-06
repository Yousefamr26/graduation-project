// QuizListWidget.dart - FIXED OVERFLOW VERSION
import 'package:flutter/material.dart';

import 'QuizQuestionsWidget.dart';

class QuizListWidget extends StatefulWidget {
  const QuizListWidget({Key? key}) : super(key: key);

  @override
  State<QuizListWidget> createState() => QuizListWidgetState();
}

class QuizListWidgetState extends State<QuizListWidget> {
  List<Map<String, dynamic>> quizzes = [];

  void _addQuiz() {
    setState(() {
      quizzes.add({
        "id": DateTime.now().millisecondsSinceEpoch,
        "titleController": TextEditingController(),
        "type": "Multiple Choice",
        "pointsController": TextEditingController(text: "0"),
        "points": 0,
        "questions": [],
      });
    });
  }

  void _removeQuiz(int index) {
    setState(() {
      quizzes[index]['titleController']?.dispose();
      quizzes[index]['pointsController']?.dispose();
      quizzes.removeAt(index);
    });
  }

  void _openQuizEditor(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizEditorScreen(
          quiz: quizzes[index],
          onSave: (updatedQuiz) {
            setState(() {
              quizzes[index]['questions'] = updatedQuiz['questions'];
              quizzes[index]['points'] = updatedQuiz['points'];
              quizzes[index]['pointsController'] = updatedQuiz['pointsController'];
            });
          },
        ),
      ),
    );
  }

  int _calculateTotalPoints(List<dynamic> questions) {
    return questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...quizzes.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> quiz = entry.value;
          TextEditingController titleController = quiz['titleController'];
          List<dynamic> questions = List.from(quiz['questions'] ?? []);
          int totalPoints = _calculateTotalPoints(questions);
          int questionCount = questions.length;

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF8FBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xff1893ff).withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1893ff).withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Header with gradient
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff1893ff), Color(0xff0d7de8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quiz ${index + 1}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                titleController.text.isEmpty
                                    ? " Quiz"
                                    : titleController.text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: () => _removeQuiz(index),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Title Input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: "Quiz Title",
                              hintText: "e.g., Week 1 Assessment",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                              labelStyle: TextStyle(color: Color(0xff1893ff)),
                              prefixIcon: Icon(Icons.edit_outlined, color: Color(0xff1893ff)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        SizedBox(height: 16),

                        // ✅ FIXED: Stats Container with better responsive design
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff1893ff).withOpacity(0.05),
                                Color(0xff1893ff).withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xff1893ff).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Questions Count
                              Flexible(
                                flex: 1,
                                child: _buildStatItem(
                                  icon: Icons.help_outline,
                                  label: "Questions",
                                  value: questionCount.toString(),
                                  color: Color(0xff1893ff),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 35,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                color: Colors.grey[300],
                              ),
                              // Total Points
                              Flexible(
                                flex: 1,
                                child: _buildStatItem(
                                  icon: Icons.stars_rounded,
                                  label: "Points",
                                  value: totalPoints.toString(),
                                  color: Colors.amber[700]!,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Questions Preview
                        if (questionCount > 0) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.preview_outlined,
                                        size: 16,
                                        color: Colors.grey[600]),
                                    SizedBox(width: 6),
                                    Text(
                                      "Questions Preview",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                ...questions.take(2).map((q) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 6),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getQuestionTypeColor(q['type']),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getQuestionTypeShort(q['type']),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            q['text'] ?? 'Question',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[50],
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.amber[200]!,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.stars,
                                                size: 11,
                                                color: Colors.amber[700],
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                "${q['points']}",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.amber[900],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                if (questionCount > 2)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "... and ${questionCount - 2} more",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 16),

                        // Edit Questions Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openQuizEditor(index),
                            icon: Icon(
                              questionCount == 0 ? Icons.add_circle_outline : Icons.edit_note,
                              size: 20,
                            ),
                            label: Text(
                              questionCount == 0
                                  ? "Add Questions"
                                  : "Edit ($questionCount)",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff1893ff),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        SizedBox(height: 8),

        // Add Quiz Button
        OutlinedButton.icon(
          onPressed: _addQuiz,
          icon: Icon(Icons.add_circle_outline, color: Color(0xff1893ff)),
          label: Text(
            "Add New Quiz",
            style: TextStyle(
              color: Color(0xff1893ff),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color(0xff1893ff), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getQuestionTypeColor(String? type) {
    switch (type) {
      case 'MultipleChoice':
        return Color(0xff1893ff);
      case 'TrueFalse':
        return Colors.purple;
      case 'ShortAnswer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeShort(String? type) {
    switch (type) {
      case 'MultipleChoice':
        return 'MCQ';
      case 'TrueFalse':
        return 'T/F';
      case 'ShortAnswer':
        return 'SA';
      default:
        return 'Q';
    }
  }
}

// Quiz Editor Screen - Full Screen
class QuizEditorScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Function(Map<String, dynamic>) onSave;

  const QuizEditorScreen({
    Key? key,
    required this.quiz,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends State<QuizEditorScreen> {
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    questions = List<Map<String, dynamic>>.from(widget.quiz['questions'] ?? []);
  }

  void _saveAndClose() {
    int totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));

    Map<String, dynamic> updatedQuiz = Map.from(widget.quiz);
    updatedQuiz['questions'] = questions;
    updatedQuiz['points'] = totalPoints;
    updatedQuiz['pointsController'] = TextEditingController(text: totalPoints.toString());

    widget.onSave(updatedQuiz);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    int totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Modern AppBar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1893ff), Color(0xff0d7de8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1893ff).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Edit Quiz Questions",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.quiz['titleController'].text.isEmpty
                                    ? "Untitled Quiz"
                                    : widget.quiz['titleController'].text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "$totalPoints",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: QuizQuestionsWidget(
                initialQuestions: questions,
                onQuestionsChanged: (updatedQuestions) {
                  setState(() {
                    questions = updatedQuestions;
                  });
                },
              ),
            ),
          ),

          // Save Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _saveAndClose,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 22),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Save ${questions.length} Question${questions.length != 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1893ff),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  minimumSize: Size(double.infinity, 54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}