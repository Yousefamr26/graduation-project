
import 'package:flutter/material.dart';
import '../../../../../../widgets/roadmapwidgets/QuizQuestionsWidget.dart';

const _kPrimary     = Color(0xff1893ff);
const _kBackground  = Color(0xffF5F7FA);

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
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List<Map<String, dynamic>>.from(
      widget.quiz['questions'] ?? [],
    );
  }

  void _save() {
    widget.onSave(
      Map<String, dynamic>.from(widget.quiz)..['questions'] = _questions,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.quiz['titleController'] as TextEditingController).text;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title.isEmpty ? 'Untitled Quiz' : title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: QuizQuestionsWidget(
        initialQuestions: _questions,
        onQuestionsChanged: (updated) =>
            setState(() => _questions = updated),
      ),
    );
  }
}