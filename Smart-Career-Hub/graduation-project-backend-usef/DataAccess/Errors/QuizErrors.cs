using DataAccess.Abstractions;

namespace Business_Logic.Errors
{
    public static class QuizErrors
    {
        // القيم الأساسية
        public static readonly Error QuizNotFound =
            new("Quiz.NotFound", "No quiz was found with the given ID");

        public static readonly Error QuizInvalidType =
            new("Quiz.InvalidType", "Invalid quiz type. Must be TrueAndFalse, MCQ, or Mixed");

        public static readonly Error QuizNull =
            new("Quiz.Null", "Quiz cannot be null");

        public static readonly Error QuizNoQuestions =
            new("Quiz.NoQuestions", "No questions provided for this quiz");

        public static readonly Error QuizEmptyTitle =
            new("Quiz.EmptyTitle", "Quiz title cannot be empty");

        public static readonly Error QuizTitleExists =
            new("Quiz.TitleExists", "A quiz with this title already exists");

        public static readonly Error QuizInvalidPoints =
            new("Quiz.InvalidPoints", "Points must be greater than zero");

        public static readonly Error QuizBulkNotFound =
            new("Quiz.BulkNotFound", "No quizzes found for the given IDs");

        public static readonly Error QuizFileInvalid =
            new("Quiz.FileInvalid", "Invalid file type. Only PDF, TXT, or DOCX are allowed");

        public static readonly Error QuizFileTooLarge =
            new("Quiz.FileTooLarge", "File size must not exceed 5MB");

        public static readonly Error QuizAnswerNotFound =
            new("QuizAnswer.NotFound", "No answer found for the given question");

        public static readonly Error QuizAnswerInvalid =
            new("QuizAnswer.Invalid", "The provided answer is invalid");
    }
}
