public record QuizScoreResponse(
       int AttemptId,
       int QuizId,
       string QuizTitle,
       int Score,           // النقاط اللي الطالب اخدها فعلاً
       int TotalPoints,     // أقصى نقاط ممكنة للكويز
       int CorrectAnswers,  // عدد الإجابات الصح
       int TotalQuestions,  // إجمالي عدد الأسئلة
       double Percentage,   // النسبة المئوية (Score / TotalPoints * 100)
       bool IsPassed,       // اتجاز لو النسبة فوق 50%
       DateTime CompletedAt
   );