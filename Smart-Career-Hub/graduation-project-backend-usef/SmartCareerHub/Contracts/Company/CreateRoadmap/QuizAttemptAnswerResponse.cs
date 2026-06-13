public record QuizAttemptAnswerResponse(
       int QuestionId,
       string QuestionText,
       string? UserAnswer,
       string? CorrectAnswer,
       bool IsCorrect
   );
