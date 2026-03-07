// QuizListWidget.dart - WHITE & BLUE THEME
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

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
        "type": "MCQ",
        "pointsController": TextEditingController(text: "0"),
        "points": 0,
        "questions": [],
        "pdfBytes": null,
        "pdfFileName": null,
        "pdfPoints": 0,
      });
    });
    debugPrint("✅ Quiz added. Total: ${quizzes.length}");
  }

  void _removeQuiz(int index) {
    setState(() {
      quizzes[index]['titleController']?.dispose();
      quizzes[index]['pointsController']?.dispose();
      quizzes.removeAt(index);
    });
    debugPrint("🗑️ Quiz removed. Total: ${quizzes.length}");
  }

  Future<void> _uploadPDFAsQuestion(int quizIndex) async {
    TextEditingController pointsController = TextEditingController(text: "10");

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xff1893ff).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.picture_as_pdf, color: Color(0xff1893ff), size: 24),
            ),
            SizedBox(width: 12),
            Expanded(child: Text("Upload PDF as Question", style: TextStyle(color: Color(0xff1893ff)))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This PDF will be treated as a single question.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              "Points for this PDF:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff1893ff)),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xff1893ff).withOpacity(0.3), width: 2),
              ),
              child: TextField(
                controller: pointsController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.stars_rounded, color: Color(0xff1893ff)),
                  hintText: "Enter points (e.g., 10)",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff1893ff),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: Icon(Icons.upload_file, size: 18),
            label: Text("Upload PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    int pdfPoints = int.tryParse(pointsController.text) ?? 10;

    try {
      print("📎 Selecting PDF file...");

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        String fileName = result.files.single.name;
        List<int> pdfBytes = result.files.single.bytes!;

        setState(() {
          quizzes[quizIndex]['pdfBytes'] = pdfBytes;
          quizzes[quizIndex]['pdfFileName'] = fileName;
          quizzes[quizIndex]['pdfPoints'] = pdfPoints;
        });

        print("✅ PDF uploaded: $fileName");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('PDF uploaded with $pdfPoints points!'),
                  ),
                ],
              ),
              backgroundColor: Color(0xff1893ff),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error uploading PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _removePDFQuestion(int quizIndex) {
    setState(() {
      quizzes[quizIndex]['pdfBytes'] = null;
      quizzes[quizIndex]['pdfFileName'] = null;
      quizzes[quizIndex]['pdfPoints'] = 0;
    });
    print("🗑️ PDF question removed");
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

  int _calculateTotalPoints(List<dynamic> questions, int pdfPoints) {
    int questionsPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));
    return questionsPoints + pdfPoints;
  }

  List<Map<String, dynamic>> getQuizzesForBackend() {
    return quizzes.map((quiz) {
      List<dynamic> questions = quiz['questions'] ?? [];
      int pdfPoints = quiz['pdfPoints'] ?? 0;

      return {
        "title": quiz['titleController'].text,
        "type": quiz['type'] ?? 'MCQ',
        "points": _calculateTotalPoints(questions, pdfPoints),
        "questions": questions.map((q) {
          return {
            "text": q['text'] ?? '',
            "type": q['type'] ?? 'MCQ',
            "optionsJson": jsonEncode(q['options'] ?? []),
            "correctAnswer": q['correctAnswer'] ?? '',
            "points": q['points'] ?? 5,
          };
        }).toList(),
        "pdfBytes": quiz['pdfBytes'],
        "pdfFileName": quiz['pdfFileName'],
        "pdfPoints": pdfPoints,
      };
    }).toList();
  }

  Widget _buildPDFQuestionSection(int quizIndex) {
    var quiz = quizzes[quizIndex];
    String? fileName = quiz['pdfFileName'];
    dynamic pdfBytes = quiz['pdfBytes'];
    int pdfPoints = quiz['pdfPoints'] ?? 0;

    if (fileName == null || pdfBytes == null) {
      return Container(
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.grey[400], size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No PDF Question',
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton.icon(
              onPressed: () => _uploadPDFAsQuestion(quizIndex),
              icon: Icon(Icons.add_circle_outline, size: 18),
              label: Text('Add PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xff1893ff),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xff1893ff).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Color(0xff1893ff).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xff1893ff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.picture_as_pdf, color: Color(0xff1893ff), size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PDF Question",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xff1893ff).withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff1893ff),
                    fontWeight: FontWeight.bold,
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
              color: Color(0xff1893ff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "$pdfPoints",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
            onPressed: () => _removePDFQuestion(quizIndex),
            constraints: BoxConstraints(),
            padding: EdgeInsets.all(6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (quizzes.isEmpty)
          Container(
            padding: EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xff1893ff).withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1893ff).withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xff1893ff).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.quiz_outlined, size: 60, color: Color(0xff1893ff)),
                ),
                SizedBox(height: 20),
                Text(
                  "No Quizzes Yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1893ff),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Start by adding a quiz",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

        ...quizzes.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> quiz = entry.value;
          TextEditingController titleController = quiz['titleController'];
          List<dynamic> questions = List.from(quiz['questions'] ?? []);
          int pdfPoints = quiz['pdfPoints'] ?? 0;
          int totalPoints = _calculateTotalPoints(questions, pdfPoints);
          int questionCount = questions.length;
          bool hasPDF = quiz['pdfBytes'] != null;

          return Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xff1893ff).withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff1893ff).withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff1893ff), Color(0xff0d7de8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.quiz_outlined, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quiz ${index + 1}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              titleController.text.isEmpty ? "Untitled Quiz" : titleController.text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.white, size: 24),
                        onPressed: () => _removeQuiz(index),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xff1893ff).withOpacity(0.3), width: 2),
                        ),
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Quiz Title",
                            hintText: "e.g., Week 1 Assessment",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                            labelStyle: TextStyle(color: Color(0xff1893ff), fontWeight: FontWeight.w600),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.edit_outlined, color: Color(0xff1893ff)),
                          ),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff1893ff).withOpacity(0.1),
                              Color(0xff1893ff).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xff1893ff).withOpacity(0.2), width: 2),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff1893ff).withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.help_outline, color: Color(0xff1893ff), size: 24),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "${questionCount + (hasPDF ? 1 : 0)}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1893ff),
                                      ),
                                    ),
                                    Text(
                                      "Questions",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 2,
                                color: Color(0xff1893ff).withOpacity(0.2),
                                margin: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xff1893ff),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff1893ff).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "$totalPoints",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1893ff),
                                      ),
                                    ),
                                    Text(
                                      "Points",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildPDFQuestionSection(index),

                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _openQuizEditor(index),
                        icon: Icon(
                          questionCount == 0 ? Icons.add_circle_outline : Icons.edit_note,
                          size: 20,
                        ),
                        label: Text(
                          questionCount == 0 ? "Add Manual Questions" : "Edit Questions ($questionCount)",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff1893ff),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: Size(double.infinity, 52),
                          elevation: 4,
                          shadowColor: Color(0xff1893ff).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _addQuiz,
          icon: Icon(Icons.add_circle_outline, color: Color(0xff1893ff), size: 24),
          label: Text(
            "Add New Quiz",
            style: TextStyle(
              color: Color(0xff1893ff),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color(0xff1893ff), width: 2.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Quiz Editor Screen
class QuizEditorScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Function(Map<String, dynamic>) onSave;

  const QuizEditorScreen({Key? key, required this.quiz, required this.onSave}) : super(key: key);

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
    int pdfPoints = widget.quiz['pdfPoints'] ?? 0;
    int questionsPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));
    int totalPoints = questionsPoints + pdfPoints;

    Map<String, dynamic> updatedQuiz = Map.from(widget.quiz);
    updatedQuiz['questions'] = questions;
    updatedQuiz['points'] = totalPoints;
    updatedQuiz['pointsController'] = TextEditingController(text: totalPoints.toString());
    widget.onSave(updatedQuiz);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FBFF),
      body: Column(
        children: [
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
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.quiz['titleController'].text.isEmpty ? "Untitled Quiz" : widget.quiz['titleController'].text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.white, size: 26),
                      onPressed: _saveAndClose,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: QuizQuestionsWidget(
              initialQuestions: questions,
              onQuestionsChanged: (updated) => setState(() => questions = updated),
            ),
          ),
        ],
      ),
    );
  }
}