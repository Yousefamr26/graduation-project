// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../../../data/repositories/roadmap_repository.dart';

class AiQuizScreen extends StatefulWidget {
  final int roadmapId;
  final bool isPublished;

  const AiQuizScreen({
    Key? key,
    required this.roadmapId,
    required this.isPublished,
  }) : super(key: key);

  @override
  State<AiQuizScreen> createState() => _AiQuizScreenState();
}

class _AiQuizScreenState extends State<AiQuizScreen> {
  final RoadmapRepository _repo = RoadmapRepository();

  String _selectedType  = 'MCQ';
  int    _numQuestions  = 5;
  bool   _isGenerating  = false;
  bool   _isGenerated   = false;
  Map<String, dynamic>? _generatedQuiz;
  String? _errorMessage;

  Future<void> _generateQuiz() async {
    if (!mounted) return;
    setState(() {
      _isGenerating  = true;
      _errorMessage  = null;
      _isGenerated   = false;
      _generatedQuiz = null;
    });

    try {
      final genResponse = await _repo.generateAiQuiz(
        roadmapId:    widget.roadmapId,
        quizType:     _selectedType,
        numQuestions: _numQuestions,
      );

      if (genResponse == null ||
          (genResponse.statusCode != 200 &&
              genResponse.statusCode != 201 &&
              genResponse.statusCode != 202)) {
        setState(() {
          _errorMessage = "Failed to generate quiz (${genResponse?.statusCode})";
          _isGenerating = false;
        });
        return;
      }

      const maxRetries = 20;
      const delay = Duration(seconds: 3);

      for (int i = 0; i < maxRetries; i++) {
        await Future.delayed(delay);
        if (!mounted) return;

        final fetchResponse = await _repo.getGeneratedQuiz(widget.roadmapId);
        if (fetchResponse == null) continue;

        debugPrint("🔄 [POLL $i] Status: ${fetchResponse.statusCode}");

        final responseData = fetchResponse.data;

        if (responseData is Map) {
          final status = responseData['status'];
          final code   = responseData['code'];

          if (status == 'PENDING' || code == 'QUIZ_NOT_READY') continue;

          if (status == 'COMPLETED' || responseData['data'] != null) {
            final parsed = _parseQuiz(responseData, _selectedType);
            debugPrint("✅ [PARSED] Questions count: ${parsed['questions']?.length}");

            if (!mounted) return;
            setState(() {
              _generatedQuiz = parsed;
              _isGenerated   = parsed['questions'] != null &&
                  (parsed['questions'] as List).isNotEmpty;
              _isGenerating  = false;
            });
            return;
          }
        }
      }

      setState(() {
        _errorMessage = "Quiz generation timed out. Try again.";
        _isGenerating = false;
      });

    } catch (e) {
      debugPrint("❌ [AI QUIZ SCREEN] Error: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }
  bool _isTrueCorrect(String correctAnswer, dynamic options) {
    final ca = correctAnswer.toLowerCase().trim();

    if (ca == 'true') return true;
    if (ca == 'a' || ca == '1') return true;

    if (options is List && options.isNotEmpty) {
      if (ca.length == 1 && ca.codeUnitAt(0) >= 97) {
        final idx = ca.codeUnitAt(0) - 97;
        if (idx < options.length) {
          return options[idx].toString().toLowerCase().contains('true');
        }
      }
      final firstOpt = options[0].toString().toLowerCase();
      if (firstOpt.contains('true') &&
          (ca == 'a' || ca.startsWith('a)') || firstOpt.startsWith(ca))) {
        return true;
      }
    }

    return false;
  }

  bool _isFalseCorrect(String correctAnswer, dynamic options) {
    final ca = correctAnswer.toLowerCase().trim();

    if (ca == 'false') return true;
    if (ca == 'b' || ca == '2') return true;

    if (options is List && options.length >= 2) {
      if (ca.length == 1 && ca.codeUnitAt(0) >= 97) {
        final idx = ca.codeUnitAt(0) - 97;
        if (idx < options.length) {
          return options[idx].toString().toLowerCase().contains('false');
        }
      }
      final secondOpt = options[1].toString().toLowerCase();
      if (secondOpt.contains('false') &&
          (ca == 'b' || ca.startsWith('b)') || secondOpt.startsWith(ca))) {
        return true;
      }
    }

    return false;
  }
  Map<String, dynamic> _parseQuiz(dynamic responseData, String quizType) {
    try {
      if (responseData is! Map) return {'questions': [], 'quizType': quizType};

      final dataList = responseData['data'];
      if (dataList == null || dataList is! List || dataList.isEmpty) {
        debugPrint("❌ [PARSE] data list is null or empty");
        return {'questions': [], 'quizType': quizType};
      }

      final firstQuiz = dataList[0];
      if (firstQuiz is! Map) return {'questions': [], 'quizType': quizType};

      final rawQuestions = firstQuiz['questions'];
      if (rawQuestions == null || rawQuestions is! List) {
        debugPrint("❌ [PARSE] questions is null or not a list");
        return {'questions': [], 'quizType': quizType};
      }

      final quizTotalPoints   = (firstQuiz['points'] as num? ?? 0).toInt();
      final questionCount     = rawQuestions.length;
      final pointsPerQuestion = questionCount > 0
          ? (quizTotalPoints / questionCount).round()
          : 0;

      debugPrint("✅ [POINTS] Quiz total: $quizTotalPoints | Per question: $pointsPerQuestion");

      final parsedQuestions = rawQuestions.map((q) {
        final question = Map<String, dynamic>.from(q as Map);

        final optionsRaw = question['optionsJson'];
        if (optionsRaw is String) {
          try {
            question['options'] = jsonDecode(optionsRaw) as List;
          } catch (_) {
            question['options'] = [];
          }
        } else if (optionsRaw is List) {
          question['options'] = optionsRaw;
        } else {
          question['options'] = [];
        }

        question['points'] ??= pointsPerQuestion;
        question['type'] = _detectQuestionType(question, quizType);

        debugPrint("🔍 [Q TYPE] '${question['text']}' → type: ${question['type']}");

        return question;
      }).toList();

      debugPrint("✅ [PARSE] Parsed ${parsedQuestions.length} questions");
      return {
        'questions':  parsedQuestions,
        'quizPoints': quizTotalPoints,
        'quizId':     firstQuiz['id'],
        'quizType':   quizType,
      };

    } catch (e) {
      debugPrint("❌ [PARSE QUIZ] Error: $e");
      return {'questions': [], 'quizType': quizType};
    }
  }

  String _detectQuestionType(Map<String, dynamic> question, String fallbackType) {
    if (fallbackType == 'TrueFalse') return 'TrueFalse';

    final options = question['options'];
    if (options is List && options.isNotEmpty) return 'MCQ';

    final answer = (question['correctAnswer'] ?? question['answer'] ?? '')
        .toString()
        .toLowerCase();
    if (answer == 'true' || answer == 'false') return 'TrueFalse';

    return fallbackType;
  }

  List<dynamic> get _questions {
    if (_generatedQuiz == null) return [];
    return _generatedQuiz!['questions'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  _buildConfigCard(),
                  const SizedBox(height: 16),
                  if (_isGenerating) _buildLoadingWidget(),
                  if (_errorMessage != null) _buildErrorWidget(),
                  if (_isGenerated && _generatedQuiz != null) ...[
                    _buildSuccessHeader(),
                    const SizedBox(height: 12),
                    ..._questions.asMap().entries.map(
                          (e) => _buildQuestionCard(e.key, e.value),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff1676C4),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _onSkip,
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Quiz Generator",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text("Generate quiz from your roadmap content",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff1676C4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff1676C4).withOpacity(0.2)),
      ),
      child: const Row(children: [
        Icon(Icons.auto_awesome, color: Color(0xff1676C4), size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'AI will generate quiz questions based on your roadmap materials. '
                'You can review them before saving.',
            style: TextStyle(fontSize: 13, color: Color(0xff1676C4)),
          ),
        ),
      ]),
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quiz Settings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          const Text("Question Type",
              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _typeBtn('MCQ',       'Multiple Choice', Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(child: _typeBtn('TrueFalse', 'True / False',   Icons.check_circle_outline)),
          ]),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Number of Questions",
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff1676C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_numQuestions',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1676C4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xff1676C4),
              inactiveTrackColor: const Color(0xff1676C4).withOpacity(0.2),
              thumbColor: const Color(0xff1676C4),
              overlayColor: const Color(0xff1676C4).withOpacity(0.1),
              valueIndicatorColor: const Color(0xff1676C4),
            ),
            child: Slider(
              value: _numQuestions.toDouble(),
              min: 1,
              max: 5,           // ✅ كان 20
              divisions: 4,     // ✅ كان 19
              label: '$_numQuestions',
              onChanged: (v) => setState(() => _numQuestions = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text('Max 5 questions', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text('5', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateQuiz,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(
                _isGenerated ? 'Regenerate Quiz' : 'Generate Quiz',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff1676C4) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xff1676C4) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600], size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        const CircularProgressIndicator(color: Color(0xff1676C4)),
        const SizedBox(height: 16),
        Text(
          "AI is generating ${_selectedType == 'TrueFalse' ? 'True/False' : 'MCQ'} quiz...",
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xff1676C4)),
        ),
        const SizedBox(height: 6),
        Text("This may take a few seconds",
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.red),
        const SizedBox(width: 10),
        Expanded(
          child: Text(_errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _buildSuccessHeader() {
    final quizPoints = _generatedQuiz?['quizPoints'];
    final quizType   = _generatedQuiz?['quizType'] ?? _selectedType;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${_questions.length} ${quizType == 'TrueFalse' ? 'True/False' : 'MCQ'} Questions Generated!',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Review the questions below before saving'
                  '${quizPoints != null ? ' • Total: $quizPoints pts' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.green[700]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuestionCard(int index, dynamic question) {
    final q = question is Map ? Map<String, dynamic>.from(question) : <String, dynamic>{};
    final text          = q['text'] ?? q['questionText'] ?? 'Question ${index + 1}';
    final correctAnswer = (q['correctAnswer'] ?? q['answer'] ?? '').toString().trim();
    final options       = q['options'] ?? q['choices'] ?? <dynamic>[];
    final points        = q['points'] ?? 0;

    final questionType = (q['type'] ?? _selectedType).toString();
    final isMCQ        = questionType == 'MCQ';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                color: Color(0xff1676C4), shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isMCQ
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isMCQ ? 'MCQ' : 'T/F',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isMCQ ? Colors.blue[700] : Colors.purple[700],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stars, size: 14, color: Colors.amber),
                const SizedBox(width: 3),
                Text('$points pts',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),

          const SizedBox(height: 12),

          if (isMCQ) ...[
            ...List.generate((options as List).length, (i) {
              final opt = options[i].toString().trim();

              bool isCorrect = false;
              if (opt.isNotEmpty && correctAnswer.isNotEmpty) {
                if (correctAnswer.length == 1 &&
                    opt.length >= 2 &&
                    opt[1] == ')') {
                  isCorrect = opt[0].toUpperCase() == correctAnswer.toUpperCase();
                } else if (opt.toUpperCase() == correctAnswer.toUpperCase()) {
                  isCorrect = true;
                } else if (opt.toUpperCase().startsWith(correctAnswer.toUpperCase())) {
                  isCorrect = true;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.4)
                        : Colors.grey[200]!,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: isCorrect ? Colors.green : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(opt,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCorrect ? Colors.green[800] : Colors.grey[800],
                          fontWeight: isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                  ),
                ]),
              );
            }),
          ] else ...[
            Row(children: [
              _tfChip('True',  _isTrueCorrect(correctAnswer, options)),
              _tfChip('False', _isFalseCorrect(correctAnswer, options)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _tfChip(String label, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.4) : Colors.grey[200]!,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isCorrect ? Colors.green : Colors.grey[400],
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: isCorrect ? Colors.green[800] : Colors.grey[700],
              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            )),
      ]),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _onSkip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(
                    color: Colors.grey[400]!,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSkip() => Navigator.pop(context, true);
  void _onDone() => Navigator.pop(context, true);
}