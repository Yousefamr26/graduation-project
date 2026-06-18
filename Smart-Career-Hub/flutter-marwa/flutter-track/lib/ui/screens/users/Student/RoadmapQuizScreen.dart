import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/Student/quiz-model.dart';
import 'cubit/quiz/quiz_cubit.dart';
import 'cubit/quiz/quiz_state.dart';

class RoadmapQuizScreen extends StatefulWidget {
  final String roadmapId;
  final String? roadmapTitle;

  const RoadmapQuizScreen({
    super.key,
    required this.roadmapId,
    this.roadmapTitle,
  });

  @override
  State<RoadmapQuizScreen> createState() => _RoadmapQuizScreenState();
}

class _RoadmapQuizScreenState extends State<RoadmapQuizScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg = Color(0xffF0F9FF);
  static const Color kCardBg = Colors.white;
  static const Color kTextDark = Color(0xff1E293B);
  static const Color kTextMuted = Color(0xff64748B);
  static const Color kBorder = Color(0xffE2E8F0);

  int _currentIndex = 0;
  bool _showReview = false;

  void _nextQuestion(int totalQuestions, BuildContext context, QuizLoaded state) {
    if (_currentIndex < totalQuestions - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showSubmitConfirmation(context, state);
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _showSubmitConfirmation(BuildContext context, QuizLoaded state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Quiz?'),
        content: Text('You have answered ${state.selectedAnswers.length} out of ${state.quiz.questions.length} questions. Are you sure you want to submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QuizCubit>().submitQuiz(widget.roadmapId, state.quiz.id.toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Quiz?'),
        content: const Text('Your current quiz progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // pop dialog
              Navigator.pop(context); // pop screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizCubit>(
      create: (context) => QuizCubit()..loadQuiz(widget.roadmapId),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: kBg,
            body: SafeArea(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _buildAppBar(context, state),
                      Expanded(
                        child: _buildBody(context, state),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, QuizState state) {
    int? currentQ;
    int? totalQ;
    bool isFinished = state is QuizFinished;

    if (state is QuizLoaded) {
      currentQ = _currentIndex + 1;
      totalQ = state.quiz.questions.length;
    } else if (state is QuizSubmitting) {
      currentQ = state.quiz.questions.length;
      totalQ = state.quiz.questions.length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDark, size: 20),
            onPressed: () {
              if (!isFinished && state is QuizLoaded) {
                _showExitConfirmation();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roadmapTitle ?? 'Roadmap Quiz',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isFinished ? 'Results Summary' : 'AI Generated Assessment',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextMuted,
                  ),
                ),
              ],
            ),
          ),
          if (currentQ != null && totalQ != null && !isFinished)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Q: $currentQ/$totalQ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    if (state is QuizLoading || state is QuizInitial) {
      return _buildLoadingState();
    }
    if (state is QuizError) {
      return _buildErrorState(context, state.message);
    }
    if (state is QuizLoaded) {
      return _buildQuizState(context, state);
    }
    if (state is QuizSubmitting) {
      return _buildSubmittingState();
    }
    if (state is QuizFinished) {
      return _buildResultsState(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: kPrimary),
          const SizedBox(height: 20),
          const Text(
            'Preparing your AI quiz...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Retrieving and formulating questions',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: kPrimary),
          const SizedBox(height: 20),
          const Text(
            'Submitting answers...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Calculating score and checking results',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error Encountered',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<QuizCubit>().loadQuiz(widget.roadmapId),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizState(BuildContext context, QuizLoaded state) {
    // Guard: no questions available
    if (state.quiz.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.quiz_outlined, color: Colors.amber[700], size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Questions Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This quiz has no questions yet.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = state.quiz.questions[_currentIndex];
    final qId = question.id.toString();
    final text = question.text;
    final options = question.options;
    final points = question.points;
    final selectedOption = state.selectedAnswers[qId];

    final progress = (_currentIndex + 1) / state.quiz.questions.length;

    return Column(
      children: [
        // Top progress line
        LinearProgressIndicator(
          value: progress,
          backgroundColor: kBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
          minHeight: 4,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '$points pts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Question ${_currentIndex + 1} of ${state.quiz.questions.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'SELECT THE CORRECT OPTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: kTextMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                // Options List
                ...options.map((opt) {
                  final isSelected = selectedOption == opt;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Material(
                      color: isSelected ? kPrimary.withOpacity(0.06) : kCardBg,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          context.read<QuizCubit>().selectAnswer(
                            qId,
                            opt,
                            widget.roadmapId,
                            state.quiz.id.toString(),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? kPrimary : kBorder,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? kPrimary : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? kPrimary : kTextMuted.withOpacity(0.5),
                                    width: 2.0,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? kPrimaryDark : kTextDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        _buildNavigationControls(context, state),
      ],
    );
  }

  Widget _buildNavigationControls(BuildContext context, QuizLoaded state) {
    final isLast = _currentIndex == state.quiz.questions.length - 1;
    final currentQId = state.quiz.questions[_currentIndex].id.toString();
    final hasAnswered = state.selectedAnswers[currentQId] != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _currentIndex > 0 ? _prevQuestion : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: hasAnswered ? () => _nextQuestion(state.quiz.questions.length, context, state) : null,
            icon: Icon(isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 18),
            label: Text(isLast ? 'Finish Quiz' : 'Next'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState(BuildContext context, QuizFinished state) {
    final percentage = state.score.clamp(0.0, 100.0);
    final String statusMsg;
    final IconData statusIcon;
    final Color statusColor;

    if (percentage >= 80) {
      statusMsg = 'Exceptional job! You have fully mastered this section.';
      statusIcon = Icons.military_tech_rounded;
      statusColor = Colors.green;
    } else if (percentage >= 50) {
      statusMsg = 'Good effort! Re-read the resources to boost your score.';
      statusIcon = Icons.thumb_up_alt_rounded;
      statusColor = Colors.blueAccent;
    } else {
      statusMsg = 'Keep practicing! Reviewing the materials again will help.';
      statusIcon = Icons.psychology_rounded;
      statusColor = Colors.orangeAccent;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextMuted,
                  ),
                ),
                const Divider(height: 32, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildResultMetric(
                      value: '${percentage.toInt()}%',
                      label: 'Your Score',
                      color: kPrimary,
                    ),
                    _buildResultMetric(
                      value: '${state.selectedAnswers.length}/${state.quiz.questions.length}',
                      label: 'Questions',
                      color: kTextDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showReview = !_showReview;
                    });
                  },
                  icon: Icon(_showReview ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                  label: Text(_showReview ? 'Hide Review' : 'Review Answers'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (_showReview) ...[
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'QUESTION BY QUESTION REVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...state.quiz.questions.asMap().entries.map((e) => _buildQuestionReviewCard(e.key, e.value, state)),
          ],
        ],
      ),
    );
  }

  Widget _buildResultMetric({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kTextMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReviewCard(int idx, QuizQuestion question, QuizFinished state) {
    final qId = question.id.toString();
    final text = question.text;
    final options = question.options;
    final userAns = state.selectedAnswers[qId];

    // Attempt to locate correct answer from correctAnswers
    String? correctAns;
    if (state.correctAnswers.isNotEmpty) {
      final match = state.correctAnswers.firstWhere(
        (ans) => ans is Map && (ans['questionId']?.toString() == qId || ans['question_id']?.toString() == qId),
        orElse: () => null,
      );
      if (match is Map) {
        correctAns = (match['correctAnswer'] ?? match['answer'] ?? match['correct_answer'] ?? '').toString();
      }
    }

    // Fallback if not loaded, check question correctAnswer
    correctAns ??= question.correctAnswer;

    final isCorrect = userAns != null && correctAns.isNotEmpty &&
        (userAns.trim().toLowerCase() == correctAns.trim().toLowerCase() ||
         (correctAns.length == 1 && userAns.trim().toUpperCase().startsWith(correctAns.toUpperCase())));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCorrect ? Colors.green[50] : Colors.red[50],
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  size: 14,
                  color: isCorrect ? Colors.green : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Question ${idx + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          // Options List showing review colors
          ...options.map((opt) {
            final isUserSelection = userAns == opt;
            
            // Correct selection matching logic
            bool isCorrectSelection = false;
            if (correctAns != null && correctAns.isNotEmpty) {
              if (opt.trim().toLowerCase() == correctAns.trim().toLowerCase()) {
                isCorrectSelection = true;
              } else if (correctAns.length == 1 && opt.trim().toUpperCase().startsWith(correctAns.toUpperCase())) {
                isCorrectSelection = true;
              }
            }
            
            Color tileBorder = kBorder;
            Color tileBg = Colors.transparent;
            Color textCol = kTextDark;
            IconData? suffixIcon;
            Color? suffixIconCol;

            if (isCorrectSelection) {
              tileBorder = Colors.green;
              tileBg = Colors.green.withOpacity(0.06);
              textCol = Colors.green[800]!;
              suffixIcon = Icons.check_circle_rounded;
              suffixIconCol = Colors.green;
            } else if (isUserSelection) {
              tileBorder = Colors.redAccent;
              tileBg = Colors.red[50]!;
              textCol = Colors.red[800]!;
              suffixIcon = Icons.cancel_rounded;
              suffixIconCol = Colors.redAccent;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tileBg,
                border: Border.all(color: tileBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 13,
                        color: textCol,
                        fontWeight: (isUserSelection || isCorrectSelection) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (suffixIcon != null)
                    Icon(suffixIcon, size: 16, color: suffixIconCol),
                ],
              ),
            );
          }),
          if (correctAns.isEmpty && userAns != null) ...[
            const SizedBox(height: 8),
            Text(
              'Your Answer: $userAns',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
