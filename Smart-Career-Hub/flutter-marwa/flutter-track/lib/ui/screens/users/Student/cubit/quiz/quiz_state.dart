import 'package:flutter/foundation.dart';
import '../../../../../../../data/models/Student/quiz-model.dart';

@immutable
abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final QuizModel quiz;
  final Map<String, String> selectedAnswers;

  QuizLoaded({
    required this.quiz,
    required this.selectedAnswers,
  });

  QuizLoaded copyWith({
    QuizModel? quiz,
    Map<String, String>? selectedAnswers,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class QuizSubmitting extends QuizState {
  final QuizModel quiz;
  final Map<String, String> selectedAnswers;

  QuizSubmitting({
    required this.quiz,
    required this.selectedAnswers,
  });
}

class QuizFinished extends QuizState {
  final double score;
  final List<dynamic> correctAnswers;
  final QuizModel quiz;
  final Map<String, String> selectedAnswers;

  QuizFinished({
    required this.score,
    required this.correctAnswers,
    required this.quiz,
    required this.selectedAnswers,
  });
}

class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}
